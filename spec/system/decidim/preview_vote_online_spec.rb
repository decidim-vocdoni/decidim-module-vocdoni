# frozen_string_literal: true

require "spec_helper"

describe "Preview vote online in an election", type: :system do
  let(:manifest_name) { "vocdoni" }
  let!(:election) { create :vocdoni_election, :upcoming, :published, :simple, component: component }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:organization) { component.organization }
  let!(:elections) { create_list(:vocdoni_election, 2, :vote, component: component) } # prevents redirect to single election page
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_vocdoni }

  before do
    switch_to_host(organization.host)
    election.reload # forces to reload the questions in the right order
    login_as admin, scope: :user
  end

  include_context "with a component"

  describe "preview voting with the admin" do
    it "can vote", :slow do
      visit_component
      click_link translated(election.title)
      click_link "Preview"

      expect(page).to have_content("This is a preview of the voting booth.")

      uses_the_voting_booth({ email: admin.email, token: "123456" })
      page.find("a.focus__exit").click

      expect(page).to have_current_path router.election_path(id: election.id)
    end

    context "when there's description in a question" do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Vocdoni::Answer.update_all(description: { en: "Some text" })
        # rubocop:enable Rails/SkipsModelValidations
      end

      it "shows a link to view more information about the election" do
        visit_component
        click_link translated(election.title)
        click_link "Preview"
        login_step({ email: admin.email, token: "123456" })
        expect(page).to have_content("MORE INFORMATION")
      end
    end

    context "when there's no description in a question" do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Vocdoni::Answer.update_all(description: {})
        # rubocop:enable Rails/SkipsModelValidations
      end

      it "does not show the more information link" do
        visit_component
        click_link translated(election.title)
        click_link "Preview"
        expect(page).not_to have_content("MORE INFORMATION")
      end
    end
  end

  context "when the election is not published" do
    let(:election) { create :vocdoni_election, :upcoming, :simple, component: component }

    it_behaves_like "allows admins to preview the voting booth"
  end

  context "when the election has not started yet" do
    let(:election) { create :vocdoni_election, :upcoming, :published, :simple, component: component }

    it_behaves_like "allows admins to preview the voting booth"
  end

  # TODO: enable when we have results/finished elections
  # context "when the election has finished" do
  #   let(:election) { create :vocdoni_election, :finished, :published, :simple, component: component }
  #
  #   it_behaves_like "doesn't allow admins to preview the voting booth"
  # end

  context "when the ballot was not send" do
    it "is alerted when trying to leave the component before completing" do
      visit_component

      click_link translated(election.title)
      click_link "Preview"

      dismiss_prompt do
        page.find("a.focus__exit").click
      end

      expect(page).to have_content("Access")
    end
  end
end
