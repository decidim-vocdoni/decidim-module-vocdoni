# frozen_string_literal: true

require "spec_helper"

describe "Votes overwrite", type: :system do
  include Rails.application.routes.url_helpers
  let(:manifest_name) { "vocdoni" }
  let!(:election) { create :vocdoni_election, :upcoming, :published, :simple, component: component }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:organization) { component.organization }
  let!(:elections) { create_list(:vocdoni_election, 2, :vote, component: component) } # prevents redirect to single election page
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_vocdoni }

  before do
    switch_to_host(organization.host)
    election.reload # forces to reload the questions in the right order
    login_as user, scope: :user
  end

  include_context "with a component"

  context "when election is ongoing" do
    let!(:election) { create :vocdoni_election, :ongoing, :published, :simple, component: component }
    let(:votes_left_url) { router.votes_left_election_votes_path(election.id) }

    # before do
    #   visit_component
    #   click_link translated(election.title)
    #
    #   click_link "Start voting"
    #
    #   stub_request(:post, votes_left_url)
    #     .to_return(body: { votes_left: votes_left }.to_json)
    # end

    context "when user has multiple votes left" do
      let(:votes_left) { 3 }

      it "displays 'can_vote_again' message", :slow, js: true do
        visit_component
        click_link translated(election.title)
        click_link "Start voting"
        login_step({ email: user.email, token: "123456" })

        wait_until(10) { page.has_content?(I18n.t("can_vote_again", scope: "decidim.vocdoni.votes.new", votes_left: votes_left)) }

        expect(page).to have_content(I18n.t("can_vote_again", scope: "decidim.vocdoni.votes.new", votes_left: votes_left))
      end

    end

    context "when user has one vote left" do
      let(:votes_left) { 1 }

      it "displays 'can_vote_one_more_time' message", :slow do
        visit_component
        click_link translated(election.title)
        click_link "Start voting"

        expect(page).to have_content(I18n.t("can_vote_one_more_time", scope: "decidim.vocdoni.votes.new"))
      end
    end

    context "when user has no more votes left" do
      let(:votes_left) { 0 }

      it "displays 'no_more_votes_left' message", :slow do
        visit_component
        click_link translated(election.title)
        click_link "Start voting"

        expect(page).to have_content(I18n.t("no_more_votes_left", scope: "decidim.vocdoni.votes.new"))
      end
    end
  end
end
