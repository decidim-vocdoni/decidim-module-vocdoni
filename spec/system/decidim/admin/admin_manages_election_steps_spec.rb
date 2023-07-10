# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election steps", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }

  include_context "when managing a component as an admin"

  describe "setup an election" do
    let(:election) { create :vocdoni_election, :ready_for_setup, component: current_component, title: { en: "English title", es: "" } }

    it "performs the action successfully" do
      visit_steps_page

      expect(page).to have_content("It's necessary to create a wallet for this organization")
      click_button "Create"
      expect(page).to have_admin_callout("Wallet successfully created")

      # Wait to let the wallet be created
      sleep 12

      within "form.create_election" do
        expect(page).to have_content("The election has at least one question.")
        expect(page).to have_content("Each question has at least two answers.")
        expect(page).to have_content("The election is published.")
        expect(page).to have_content("The census is ready")

        click_button "Setup election"
      end

      within ".form-general-submit" do
        expect(page).to have_content("Processing...")
      end

      expect(page).to have_admin_callout("successfully")

      within ".content.created" do
        expect(page).to have_content("The election has been created")
      end
    end
  end

  describe "election with manual start" do
    let(:election) { create :vocdoni_election, :ready_for_setup, :manual_start, component: current_component }

    before do
      visit_steps_page
      click_button "Create"
      sleep 12
      click_button "Setup election"
    end

    it "performs the action successfully" do
      expect(page).to have_button("Start election")
      click_button "Start election"
      accept_confirm

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_selector("li.text-warning", text: "Vote period")
    end
  end

  private

  def visit_steps_page
    election

    relogin_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-steps").click
    end
  end
end
