# frozen_string_literal: true

require "spec_helper"

describe "Vote online in an election", type: :system do
  let(:manifest_name) { "vocdoni" }
  let!(:election) { create(:vocdoni_election, :upcoming, :published, :simple, component:) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:organization) { component.organization }
  let!(:elections) { create_list(:vocdoni_election, 2, :vote, component:) } # prevents redirect to single election page
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_vocdoni }

  before do
    switch_to_host(organization.host)
    election.reload # forces to reload the questions in the right order
    login_as user, scope: :user
  end

  include_context "with a component"

  describe "voting with the current user" do
    context "when the election is ongoing" do
      let!(:election) { create(:vocdoni_election, :ongoing, :published, :simple, component:) }

      it "can access", :slow do
        visit_component
        click_link_or_button translated(election.title)

        expect(page).to have_link("Start voting")
        expect(page).to have_no_link("Preview")

        click_link_or_button "Start voting"

        expect(page).to have_content("Verify your identity")
      end
    end

    context "when the election is not published" do
      let(:election) { create(:vocdoni_election, :upcoming, :simple, component:) }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "allows admins to preview the voting booth"
    end

    context "when the election has not started yet" do
      let(:election) { create(:vocdoni_election, :upcoming, :published, :simple, component:) }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "allows admins to preview the voting booth"
    end

    context "when the election is paused" do
      let(:election) { create(:vocdoni_election, :paused, :simple, component:) }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "allows admins to preview the voting booth"
    end

    context "when the election was canceled" do
      let(:election) { create(:vocdoni_election, :canceled, :simple, component:) }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "allows admins to preview the voting booth"
    end

    context "when the election has finished" do
      let(:election) { create(:vocdoni_election, :finished, :published, :simple, component:) }

      it_behaves_like "doesn't allow to vote"
      it_behaves_like "doesn't allow admins to preview the voting booth"
    end
  end

  describe "internal census" do
    let!(:election) { create(:vocdoni_election, :ongoing, :published, :with_internal_census, component:, verification_types:) }
    let(:authorization) { create(:authorization, user:, name: "dummy_authorization_handler") }
    let(:verification_types) { [authorization.name] }

    context "when the user is not logged in" do
      before do
        logout :user
        visit_component
        click_link_or_button translated(election.title)
        click_link_or_button "Start voting"
      end

      it "shows login modal" do
        visit_component
        click_link_or_button translated(election.title)

        click_link_or_button "Start voting"

        expect(page).to have_content("Please sign in")
      end
    end

    context "when the user is logged in" do
      context "when user is not authorized" do
        let(:another_user) { create(:user, :confirmed, organization:) }

        before do
          login_as another_user, scope: :user
          visit_component
          click_link_or_button translated(election.title)
          click_link_or_button "Start voting"
        end

        it "shows a modal with required authorizations" do
          expect(page).to have_content("Authorization required")
          expect(page).to have_link("Authorize with \"Example authorization\"")
        end
      end

      context "when user is authorized" do
        before do
          login_as user, scope: :user
          visit_component
          click_link_or_button translated(election.title)
          click_link_or_button "Start voting"
        end

        it "doesn't show a modal with required authorizations" do
          expect(page).to have_no_content("Authorization required")
          expect(page).to have_no_link("Authorize with \"Example authorization\"")
        end
      end
    end

    context "when the census was created without authorized users" do
      context "when the census is not updated" do
        let!(:election) { create(:vocdoni_election, :ongoing, :published, :with_internal_census, component:, verification_types:) }
        let(:another_user) { create(:user, :confirmed, organization:) }
        let!(:voter) { create(:vocdoni_voter, election:, email: another_user.email, in_vocdoni_census: false) }
        let(:non_voter_ids) { [voter.id] }
        let(:admin) { create(:user, :admin, organization:) }

        before do
          login_as user, scope: :user
          visit_component
          click_link_or_button translated(election.title)
          click_link_or_button "Start voting"
        end

        it "shows a message to update the census" do
          expect(page).to have_content("The administrator has not yet added your wallet to the census. Please try again later")
        end
      end
    end

    context "when the census was created with authorized users" do
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:authorization) { create(:authorization, user:, name: "dummy_authorization_handler") }
      let!(:voter) { create(:vocdoni_voter, election:, email: user.email, in_vocdoni_census: true) }
      let!(:election) { create(:vocdoni_election, :ongoing, :published, :with_internal_census, component:, verification_types:) }

      before do
        login_as user, scope: :user
        visit_component
        click_link_or_button translated(election.title)
        click_link_or_button "Start voting"
      end

      it "shows a message to update the census" do
        expect(page).to have_content("We are verifying that you are eligible to vote in this election. Please wait a few seconds.")
      end
    end
  end
end
