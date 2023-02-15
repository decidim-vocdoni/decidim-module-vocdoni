# frozen_string_literal: true

require "spec_helper"

describe "Admin creates wallet", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let(:election) { create :vocdoni_election, :ready_for_setup, component: current_component, title: { en: "English title"} }

  include_context "when managing a component as an admin"

  context "when there isn't any wallet" do
    it "redirects to the wallet creation page" do
      visit_steps_page

      expect(page).to have_content("It's necessary to create a wallet for this organization")
    end

    it "creates a new wallet" do
      visit_steps_page
      click_button "Create"

      expect(page).to have_content("The election has at least one question.")
      expect(Decidim::Vocdoni::Wallet.last.private_key.length).to eq 66
    end
  end

  context "when there is a wallet" do
    let!(:wallet) { create :wallet, organization: current_component.organization }

    it "goes to the step page" do
      visit_steps_page

      expect(page).to have_content("The election has at least one question.")
    end

    it "doesn't create another wallet" do
      expect(Decidim::Vocdoni::Wallet.all.count).to eq 1
      visit Decidim::EngineRouter.admin_proxy(current_component).new_wallet_path(component: current_component.id)

      expect(page).to have_content("You are not authorized to perform this action")
      expect(Decidim::Vocdoni::Wallet.all.count).to eq 1
    end
  end

  def visit_steps_page
    election

    relogin_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-steps").click
    end
  end
end
