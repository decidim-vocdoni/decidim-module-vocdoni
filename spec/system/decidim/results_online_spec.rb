# frozen_string_literal: true

require "spec_helper"

describe "Results online" do # rubocop:disable RSpec/DescribeClass
  let(:manifest_name) { "vocdoni" }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:organization) { component.organization }
  let!(:elections) { create_list(:vocdoni_election, 2, :vote, component:) } # prevents redirect to single election page
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_vocdoni }
  let!(:wallet) { create(:vocdoni_wallet, organization:, private_key:) }
  let(:private_key) { Faker::Blockchain::Ethereum.address }

  before do
    switch_to_host(organization.host)
    election.reload # forces to reload the questions in the right order
    login_as user, scope: :user
  end

  include_context "with a component"

  context "when until_the_end is false" do
    let!(:election) { create(:vocdoni_election, :ongoing, :published, :simple, component:, election_type: { secret_until_the_end: }, vocdoni_election_id:) }
    let(:question) { create(:vocdoni_question, election:) }
    let(:answers) { create_list(:answer, 2, question:) }
    let(:secret_until_the_end) { false }
    let(:vocdoni_election_id) { "12345" }

    before do
      stub_request(:get, "https://api-dev.vocdoni.net/v2/elections/#{vocdoni_election_id}")
        .to_return(status: 200, body: <<~JSON, headers: {})
              {
          "electionId": "12345",
           "result": [["10", "12"]]
          }
        JSON
    end

    it "shows the results" do
      visit_component
      click_link_or_button translated(election.title)

      expect(page).to have_content("Vote statistics")
      expect(page).to have_css(".election__accordion-panel-result table tr td:nth-child(2)", text: "10", count: 1)
      expect(page).to have_css(".election__accordion-panel-result table tr td:nth-child(2)", text: "12", count: 1)
    end

    context "when the election is finished" do
      let(:election) { create(:vocdoni_election, :finished, :published, :simple, component:) }

      it "shows the results" do
        visit_component
        check("Finished")
        click_link_or_button translated(election.title)

        expect(page).to have_no_content("VOTE STATISTICS")
      end
    end

    context "when the election is not ongoing" do
      let(:election) { create(:vocdoni_election, :paused, :published, :simple, component:) }

      it "shows the results" do
        visit_component
        check("Upcoming")
        click_link_or_button translated(election.title)

        expect(page).to have_no_content("Vote statistics")
      end
    end
  end

  context "when until_the_end is true" do
    let(:election) { create(:vocdoni_election, :ongoing, :published, :simple, component:) }

    it "doesn't show the results" do
      visit_component
      click_link_or_button translated(election.title)

      expect(page).to have_no_content("VOTE STATISTICS")
    end
  end
end
