# frozen_string_literal: true

require "spec_helper"

describe "Vote online in an election", type: :system do
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

  describe "voting with the current user" do
    context "when the election is ongoing" do
      let!(:election) { create :vocdoni_election, :ongoing, :published, :simple, component: component }

      it "can access", :slow do
        visit_component
        click_link translated(election.title)

        expect(page).to have_link("Start voting")
        expect(page).not_to have_link("Preview")

        click_link "Start voting"

        expect(page).to have_content("Verify your identity")
      end
    end

    context "when the election is not published" do
      let(:election) { create :vocdoni_election, :upcoming, :simple, component: component }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "allows admins to preview the voting booth"
    end

    context "when the election has not started yet" do
      let(:election) { create :vocdoni_election, :upcoming, :published, :simple, component: component }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "allows admins to preview the voting booth"
    end

    context "when the election has finished" do
      let(:election) { create :vocdoni_election, :finished, :published, :simple, component: component }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "doesn't allow admins to preview the voting booth"
    end
  end
end
