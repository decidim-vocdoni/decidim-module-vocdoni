# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election steps", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let!(:wallet) { create :wallet, organization: current_component.organization, private_key: "0x42a1c49e5b72a2fb146b9aa7c4c520eadc7e97dd885ce857141ba7f2e2d58051" }

  include_context "when managing a component as an admin"

  describe "setup an election" do
    let(:election) { create :vocdoni_election, :ready_for_setup, component: current_component, title: { en: "English title", es: "" } }

    it "performs the action successfully" do
      visit_steps_page

      within "form.create_election" do
        expect(page).to have_content("The election has at least 1 question.")
        expect(page).to have_content("Each question has at least 2 answers.")
        expect(page).to have_content("The election is published.")
        expect(page).to have_content("The election component is published.")
        expect(page).to have_content("The census is ready")
        expect(find("input#setup_wallet_private_key", visible: false).value).to eq wallet.private_key

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
