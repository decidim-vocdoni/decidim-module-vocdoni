# frozen_string_literal: true

require "spec_helper"

describe "Admin creates wallet", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let!(:election) { create :vocdoni_election, :ready_for_setup, component: current_component, title: { en: "English title" } }

  include_context "when managing a component as an admin"

  context "when there isn't any wallet" do
    it "redirects to the wallet creation page" do
      visit_steps_page
      expect(page).to have_content("It's necessary to create a wallet for this organization")
      expect(page).to have_content("New organization wallet")
      click_link "Create"

      expect(page).to have_content("The election has at least one question.")
      expect(Decidim::Vocdoni::Wallet.last.private_key.length).to eq 66
    end
  end

  context "when there is a wallet" do
    let!(:wallet) { create :vocdoni_wallet, organization: current_component.organization }

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

    context "when prod environment" do
      before do
        allow(Decidim::Vocdoni).to receive(:api_endpoint_env).and_return("prod")
        allow(Decidim::Vocdoni).to receive(:vocdoni_reseller_name).and_return("Test reseller")
        allow(Decidim::Vocdoni).to receive(:vocdoni_reseller_email).and_return("test_reseller@example.org")
      end

      it "shows the information about receiving coins" do
        visit_steps_page

        expect(page).to have_content("The usage of the Vocdoni platform has costs")
        expect(page).to have_content("Test reseller")
        expect(page).to have_css("input[value='#{wallet.private_key}']")
        expected_href = "mailto:test_reseller@example.org?subject=Decidim Vocdoni Inquiry&body=Please provide a quote for the Vocdoni platform usage. My organization Vocdoni address is: 0x0000000000000000000000000000000000000000000000000000000000000001"
        expect(page).to have_css("a[href='#{expected_href}']")
      end
    end

    context "when stg environment" do
      before do
        allow(Decidim::Vocdoni).to receive(:api_endpoint_env).and_return("stg")
        allow(Decidim::Vocdoni).to receive(:vocdoni_reseller_name).and_return("Test reseller")
        allow(Decidim::Vocdoni).to receive(:vocdoni_reseller_email).and_return("test_reseller@example.org")
      end

      it "doesn't show the information about receiving coins" do
        visit_steps_page

        expect(page).not_to have_content("The usage of the Vocdoni platform has costs")
        expect(page).not_to have_content("Test reseller")
        expect(page).not_to have_css("input[value='#{wallet.private_key}']")
      end
    end
  end

  def visit_steps_page
    relogin_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-steps").click
    end
  end
end
