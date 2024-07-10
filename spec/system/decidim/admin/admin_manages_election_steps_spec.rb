# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election steps", :slow do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create(:vocdoni_component) }
  let(:info) do
    {
      clientInfo: {
        address: "0x0000000000000000000000000000000000000001",
        balance:
      }
    }
  end
  let(:balance) { 500 }
  let(:vocdoni_status) { "UPCOMING" }
  let(:vocdoni_election_id) { "123456789" }
  let!(:wallet) { create(:vocdoni_wallet, organization: current_component.organization) }
  let(:results) do
    [
      [1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15], [16, 17, 18]
    ]
  end
  let!(:create_election_result) do
    {
      "electionId" => vocdoni_election_id,
      "censusIdentifier" => "cfe4e3d3-3e3e-4e3e-3e3e-3e3e3e3e3e3e",
      "censusAddress" => "0x0000000000000000000000000000000000000002",
      "censusPrivateKey" => "0x0000000000000000000000000000000000000003",
      "censusPublicKey" => "0x0000000000000000000000000000000000000004"
    }
  end

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:info).and_return(info)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:createElection).and_return(create_election_result)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:pauseElection).and_return(true)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:electionMetadata).and_return({ "status" => vocdoni_status, "results" => results })
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:continueElection).and_return(true)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:cancelElection).and_return(true)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:endElection).and_return(true)
    # rubocop:enable RSpec/AnyInstance
  end

  include_context "when managing a component as an admin"

  describe "setup an election" do
    let!(:election) { create(:vocdoni_election, :ready_for_setup, :auto_start, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      within "form.create_election" do
        expect(page).to have_content("The election has at least one question.")
        expect(page).to have_content("Each question has at least two answers.")
        expect(page).to have_content("The election is published.")
        expect(page).to have_content("The census is ready")
        expect(page).to have_no_link("Fix it")

        perform_enqueued_jobs do
          click_link_or_button "Setup election"
        end
      end

      expect(page).to have_content("The election data has been successfully sent to the Vocdoni API")

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_no_content("Vocdoni communication error")
      expect(page).to have_content("The election has been created. We are waiting for the election to start")
      expect(page).to have_no_content("This election has been configured to start manually")
    end

    context "when manual start" do
      let!(:election) { create(:vocdoni_election, :ready_for_setup, :manual_start, component: current_component) }

      it "performs the action successfully" do
        visit_steps_page

        within "form.create_election" do
          expect(page).to have_no_link("Fix it")

          perform_enqueued_jobs do
            click_link_or_button "Setup election"
          end
        end

        expect(page).to have_content("The election data has been successfully sent to the Vocdoni API")

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_no_content("Vocdoni communication error")
        expect(page).to have_content('The election has been created. The election will start manually. Press the button "Start election" to begin the voting period.')
        expect(page).to have_content("This election has been configured to start manually")

        click_link_or_button "Start election"
        accept_confirm

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_css("li.text-warning", text: "Vote period")
      end
    end

    context "when some misconfiguration" do
      let!(:election) { create(:vocdoni_election, :ready_for_setup, :auto_start, start_time: 10.minutes.ago, component: current_component) }

      it "shows the fixit button" do
        visit_steps_page

        within "form.create_election" do
          expect(page).to have_content("The election has at least one question.")
          expect(page).to have_content("Each question has at least two answers.")
          expect(page).to have_content("The election is published.")
          expect(page).to have_content("The census is ready")
          expect(page).to have_content("The setup is not being done at least 10 minutes before the election starts.")
          expect(page).to have_link("Fix it")
          expect(page).to have_button("Setup election", disabled: true)
        end
      end
    end

    context "when the sdk call fails" do
      let(:vocdoni_election_id) { "" }

      it "shows an error" do
        visit_steps_page

        within "form.create_election" do
          perform_enqueued_jobs do
            click_link_or_button "Setup election"
          end
        end

        expect(page).to have_content("The election data has been successfully sent to the Vocdoni API")
        expect(page).to have_content("Vocdoni communication error")

        click_link_or_button "Try to resend the election data to the Vocdoni API"

        # Simulates the job
        election.update(vocdoni_election_id: "1234567890")

        expect(page).to have_no_content("Vocdoni communication error")
      end
    end

    context "when the internal census without authorizations" do
      let!(:election) { create(:vocdoni_election, :with_internal_census, :ready_for_setup, component: current_component) }

      it "has another message for internal census" do
        visit_steps_page

        within "form.create_election" do
          expect(page).to have_content("The census is ready. Selected census is: Internal (no additional authorizations are required).")
          expect(page).to have_no_link("Fix it")
          expect(page).to have_content("no additional authorizations are required")
        end
      end
    end
  end

  describe "when continuing the election" do
    let(:vocdoni_status) { "PAUSED" }
    let!(:election) { create(:vocdoni_election, :ready_for_setup, :configured, :ongoing, :paused, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      click_link_or_button "Continue the election"
      accept_confirm

      expect(page).to have_admin_callout("The election has been successfully resumed")
      expect(page).to have_css("li.text-warning", text: "Vote period")
    end

    context "and out of sync" do
      let(:vocdoni_status) { "ONGOING" }

      it "performs the action successfully" do
        visit_steps_page

        click_link_or_button "Continue the election"
        accept_confirm

        expect(page).to have_admin_callout("The election was out of sync with the Vocdoni API. The status has been updated to \"vote\". Please refresh the page")
        expect(page).to have_content("The election is currently running")
        expect(page).to have_css("li.text-warning", text: "Vote period")
      end
    end
  end

  describe "when pausing the election" do
    let(:vocdoni_status) { "ONGOING" }
    let!(:election) { create(:vocdoni_election, :ready_for_setup, :configured, :ongoing, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      click_link_or_button "Pause the election"
      accept_confirm

      expect(page).to have_admin_callout("The election has been successfully paused")
      expect(page).to have_content("The election is currently running")
      expect(page).to have_css("li.text-warning", text: "Paused")
    end
  end

  describe "canceling the election" do
    let(:vocdoni_status) { "ONGOING" }
    let!(:election) { create(:vocdoni_election, :ready_for_setup, :configured, :ongoing, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      click_link_or_button "Cancel the election (abort)"
      accept_confirm

      expect(page).to have_admin_callout("The election has been successfully canceled")
      expect(page).to have_content("This election has been canceled prematurely")
      expect(page).to have_css("li.text-warning", text: "Canceled")
    end
  end

  describe "ending the election" do
    let(:vocdoni_status) { "ONGOING" }
    let!(:election) { create(:vocdoni_election, :ready_for_setup, :configured, :ongoing, component: current_component) }

    it "performs the action successfully" do
      visit_steps_page

      click_link_or_button "End the election"
      accept_confirm

      expect(page).to have_admin_callout("The election has been ended, the results will be published in a few seconds.")
      expect(page).to have_content("The vote period has ended. You can publish the results")
      expect(page).to have_css("li.text-warning", text: "Vote period ended")
    end
  end

  describe "publishing the results" do
    let(:vocdoni_status) { "ENDED" }
    let!(:election) { create(:vocdoni_election, :ready_for_setup, :configured, :finished, component: current_component) }
    let(:answer_first) { election.questions.first.answers.first }
    let(:answer_second) { election.questions.first.answers.second }

    it "performs the action successfully" do
      visit_steps_page

      election.build_answer_values!

      perform_enqueued_jobs do
        click_link_or_button "Publish results"
      end

      expect(page).to have_admin_callout("The election has been ended, the results will be published in a few seconds.")
      expect(page).to have_css("li.text-warning", text: "Results published")
      expect(page).to have_content("Results published")

      election.questions.each_with_index do |question, idx|
        question.answers.each do |answer|
          within :xpath, "//td[contains(text(),'#{translated(answer.title)}')]/following-sibling::td[1]" do
            expect(page).to have_content((results[idx][answer.value]).to_s)
          end
        end
      end
      expect(page).to have_no_content("Publish results")
    end
  end

  context "when already published" do
    let(:vocdoni_status) { "RESULTS" }
    let!(:election) { create(:vocdoni_election, :ready_for_setup, :configured, :results_published, :published, component: current_component) }
    let(:answer_first) { election.questions.first.answers.first }
    let(:answer_second) { election.questions.first.answers.second }

    it "shows the results" do
      visit_steps_page

      election.build_answer_values!

      expect(page).to have_content("Some error occurred while publishing the results. Please try to publish them again.")

      perform_enqueued_jobs do
        click_link_or_button "Publish results"
      end

      expect(page).to have_content("Results published")

      election.questions.each_with_index do |question, idx|
        question.answers.each do |answer|
          within :xpath, "//td[contains(text(),'#{translated(answer.title)}')]/following-sibling::td[1]" do
            expect(page).to have_content((results[idx][answer.value]).to_s)
          end
        end
      end
      expect(page).to have_no_content("Publish results")
    end
  end

  describe "updating the census" do
    let!(:election) { create(:vocdoni_election, :with_internal_census, :ready_for_setup, :configured, :ongoing, component: current_component, verification_types:) }
    let(:non_voter_ids) { create_list(:user, 3, organization: current_component.organization).map(&:id) }
    let(:authorization) { create(:authorization, user:, name: "dummy_authorization_handler") }
    let(:verification_types) { [authorization.name] }

    it "performs the action successfully" do
      visit_steps_page
      expect(page).to have_content("There are 1 users waiting to be added to the census.")
      expect(page).to have_content("It is possible to update it during the duration of the election but it requires your manual action as it might cost some credits.")
      expect(page).to have_content("Example authorization")
      click_link_or_button "Update census now!"
      sleep 1
      perform_enqueued_jobs
      sleep 1
      expect(page).to have_no_css("a", text: "Update census now!")
      expect(page).to have_content("There are 0 users waiting to be added to the census.")
    end
  end

  private

  def visit_steps_page
    relogin_as user, scope: :user
    visit_component_admin

    within "tr", text: translated(election.title) do
      page.find(".action-icon--manage-steps").click
    end
  end
end
