# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election steps", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let(:info) do
    {
      clientInfo: {
        address: "0x0000000000000000000000000000000000000001",
        balance: balance
      }
    }
  end
  let(:balance) { 50 }
  let(:vocdoni_election_id) { "0x0000000000000000000000000000000000000002" }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:info).and_return(info)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:createElection).and_return(vocdoni_election_id)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:pauseElection).and_return(true)
    # rubocop:enable RSpec/AnyInstance
  end

  include_context "when managing a component as an admin"

  describe "setup an election" do
    let!(:election) { create :vocdoni_election, :ready_for_setup, component: current_component, title: { en: "English title", es: "" } }

    it "performs the action successfully" do
      visit_steps_page

      expect(page).to have_content("It's necessary to create a wallet for this organization")
      click_link "Create"
      expect(page).to have_admin_callout("Wallet successfully created")

      within "form.create_election" do
        expect(page).to have_content("The election has at least one question.")
        expect(page).to have_content("Each question has at least two answers.")
        expect(page).to have_content("The election is published.")
        expect(page).to have_content("The census is ready")

        click_button "Setup election"
      end

      expect(page).to have_content("The election is being sent to the Vocdoni API")
      perform_enqueued_jobs

      expect(page).to have_admin_callout("successfully")
      expect(page).not_to have_content("Vocdoni communication error")
      expect(page).to have_content("The election has been created")
    end

    context "when the sdk call fails" do
      let(:vocdoni_election_id) { "" }

      it "shows an error" do
        visit_steps_page

        click_link "Create"
        within "form.create_election" do
          click_button "Setup election"
        end

        perform_enqueued_jobs
        expect(page).to have_content("Vocdoni communication error")

        click_button "Try to resend the election data to the Vocdoni API"
        # simulate the job
        election.update(vocdoni_election_id: "0x0000000000000000000000000000000000000002")

        expect(page).not_to have_content("Vocdoni communication error")
        expect(page).to have_content("The election has been created")
      end
    end
  end

  describe "election with manual start" do
    let!(:election) { create :vocdoni_election, :ready_for_setup, :manual_start, :configured, component: current_component }
    let!(:wallet) { create :vocdoni_wallet, organization: organization }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:electionMetadata).and_return({ "status" => "UPCOMING" })
      allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:continueElection).and_return(true)
      # rubocop:enable RSpec/AnyInstance
    end

    it "performs the action successfully" do
      visit_steps_page
      click_button "Start election"
      accept_confirm

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_selector("li.text-warning", text: "Vote period")
    end
  end

  private

  def visit_steps_page
    relogin_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-steps").click
    end
  end
end
