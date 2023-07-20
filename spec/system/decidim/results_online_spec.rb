# frozen_string_literal: true

require "spec_helper"

describe "Results online", type: :system do
  let(:manifest_name) { "vocdoni" }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:organization) { component.organization }
  let!(:elections) { create_list(:vocdoni_election, 2, :vote, component: component) } # prevents redirect to single election page
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_vocdoni }
  let!(:wallet) { create(:wallet, organization: organization, private_key: private_key) }
  let(:private_key) { Faker::Blockchain::Ethereum.address }

  before do
    switch_to_host(organization.host)
    election.reload # forces to reload the questions in the right order
    login_as user, scope: :user
  end

  include_context "with a component"

  context "when until_the_end is false" do
    let!(:election) { create :vocdoni_election, :ongoing, :published, :simple, component: component, election_type: { secret_until_the_end: secret_until_the_end }, vocdoni_election_id: vocdoni_election_id }
    let(:question) { create :vocdoni_question, election: election }
    let(:answers) { create_list :answer, 2, question: question }
    let(:secret_until_the_end) { false }
    let(:vocdoni_election_id) { "12345" }

    before do
      stub_request(:get, "https://api-stg.vocdoni.net/v2/elections/#{vocdoni_election_id}")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "User-Agent" => "Faraday v2.7.1"
          }
        )
        .to_return(status: 200, body: <<~JSON, headers: {})
              {
          "electionId": "12345",
           "result": [["10", "12"]]
          }
        JSON
    end

    it "shows the results" do
      visit_component
      click_link translated(election.title)

      expect(page).to have_content("VOTE STATISTICS")
      expect(page).to have_css(".accordion-content table tr td:nth-child(2)", text: "10", count: 1)
      expect(page).to have_css(".accordion-content table tr td:nth-child(2)", text: "12", count: 1)
    end

    context "when the election is finished" do
      let(:election) { create :vocdoni_election, :finished, :published, :simple, component: component }

      it "shows the results" do
        visit_component
        click_link translated(election.title)

        expect(page).not_to have_content("VOTE STATISTICS")
      end
    end

    context "when the election is not ongoing" do
      let(:election) { create :vocdoni_election, :paused, :published, :simple, component: component }

      it "shows the results" do
        visit_component
        click_link translated(election.title)

        expect(page).not_to have_content("VOTE STATISTICS")
      end
    end
  end

  context "when until_the_end is true" do
    let(:election) { create :vocdoni_election, :ongoing, :published, :simple, component: component }

    it "doesn't show the results" do
      visit_component
      click_link translated(election.title)

      expect(page).not_to have_content("VOTE STATISTICS")
    end
  end
end
