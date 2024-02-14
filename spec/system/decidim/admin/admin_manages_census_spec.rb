# frozen_string_literal: true

require "spec_helper"

describe "Admin manages census", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let(:election) { create :vocdoni_election, :upcoming, :published, :complete, component: current_component, title: { en: "English title" } }

  before do
    allow(Rails.application).to receive(:secret_key_base).and_return("a-secret-key-base")
  end

  include_context "when managing a component as an admin"

  context "when there isn't any census" do
    let(:voter1) { Decidim::Vocdoni::Voter.find_by(email: "john@example.org") }
    let(:voter2) { Decidim::Vocdoni::Voter.find_by(email: "alice@example.org") }

    it "uploads the census" do
      visit_census_page

      expect(page).to have_content("Upload a CSV file")

      attach_file("census_data[file]", valid_census_file)
      perform_enqueued_jobs do
        click_button "Upload file"
      end

      expect(page).to have_content("Successfully imported 2 items")
      expect(page).to have_content("There are 2 records loaded in total")

      expect(voter1.wallet_address).to eq("0x0b9eA6587591d888f0b3a2D67f3d416246BB9304")
      expect(voter2.wallet_address).to eq("0x5D38b06B50412294532b9A2C0127AD1455Af7934")
    end
  end

  context "when there's already a census" do
    context "without the credentials" do
      let!(:voter1) { create(:vocdoni_voter, election: election, token: "123456", email: "user_1@example.org") }
      let!(:voter2) { create(:vocdoni_voter, election: election, token: "123abc", email: "user_2@example.org") }
      let!(:voter3) { create(:vocdoni_voter, election: election, token: "123abc", email: "user_3@example.org") }
      let!(:voter4) { create(:vocdoni_voter, election: election, token: "abcxyz", email: "user_4@example.org") }
      let!(:voter5) { create(:vocdoni_voter, election: election, token: "123abc", email: "user_5@example.org") }

      it "has progress indicator of the generation of the credentials" do
        visit_census_page

        expect(page).to have_content("There are 5 records loaded in total")
        expect(page).to have_content("Current census data")
        expect(page).to have_content("Completed 0% of 5 total records")

        # Simulates the percentage of completion
        wallet = Decidim::Vocdoni::Sdk.new(organization, election).deterministicWallet([voter1.email, voter1.token])["address"]
        voter1.update(wallet_address: wallet)
        voter1.reload
        sleep 1

        expect(page).to have_content("Completed 20% of 5 total records")
        expect(voter1.reload.wallet_address).to eq("0xFEA59AF4dD69C285f39CC6836DA2664f36A47A71")
        expect(voter2.reload.wallet_address).to be_nil
      end

      describe "and we want to delete it" do
        it "deletes it" do
          visit_census_page

          deletes_the_census
        end
      end
    end

    context "with the credentials" do
      let!(:voters) { create_list(:vocdoni_voter, 5, :with_wallet, election: election) }

      it "doesn't have any form" do
        visit_census_page

        expect(page).not_to have_content("Upload a new census")
        expect(page).not_to have_content("Confirm the census data")
      end

      describe "and we want to delete it" do
        it "deletes it" do
          visit_census_page

          deletes_the_census
        end
      end
    end
  end

  describe "internal census" do
    let!(:authorization_handler_name) { "dummy_authorization_handler" }
    let!(:id_document_handler_name) { "another_dummy_authorization_handler" }
    let(:translated_authorization_handler_name) { I18n.t("decidim.authorization_handlers.#{authorization_handler_name}.name") }
    let(:translated_id_document_handler_name) { I18n.t("decidim.authorization_handlers.#{id_document_handler_name}.name") }
    let!(:organization) { create(:organization, available_authorizations: available_authorizations) }
    let!(:available_authorizations) { [authorization_handler_name, id_document_handler_name] }
    let(:authorizations_count) { organization.available_authorizations.count }
    let(:authorizations_checkboxes) { find_all("input[type='checkbox'][name='census_permissions[verification_types][]']") }
    let!(:user_with_authorizations) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:user_without_authorizations) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:dummy_authorization) { create(:authorization, user: user_with_authorizations, name: id_document_handler_name) }

    before do
      visit_census_page
      choose("permissions_radio_button")
    end

    it "has Decidim permissions content" do
      expect(page).to have_content("Internal (all registered participants")
      expect(authorizations_checkboxes.count).to eq(authorizations_count)
    end

    it "has warning content for the internal census" do
      expect(page).to have_content("The census is not ready yet. You can upload the CSV file to processed.")
    end

    context "when selected any permission" do
      before do
        check(translated_id_document_handler_name)
        perform_enqueued_jobs do
          click_button "Save census"
        end
        sleep 1
      end

      it "has success message" do
        expect(page).to have_admin_callout("Successfully imported 1 items (0 errors)")
      end

      it "checks for text about uploading data to the Vocdoni blockchain" do
        expect(page).to have_content("Selected census: Internal (another example authorization)")
      end

      it "has the message that the records loaded" do
        expect(page).to have_content("There are 1 records loaded")
      end
    end

    context "when selected a few permissions" do
      before do
        check(translated_authorization_handler_name)
        check(translated_id_document_handler_name)
        perform_enqueued_jobs do
          click_button "Save census"
        end
        sleep 1
      end

      it "has message" do
        expect(page).to have_admin_callout("Successfully imported 0 items (0 errors)")
      end

      it "has the message that the data is uploaded and prepared" do
        expect(page).to have_content("Selected census: Internal (example authorization, another example authorization)")
      end

      it "has the message that the records loaded (a technical user)" do
        expect(page).to have_content("There are 1 records loaded in total.")
      end

      it "goes to the next step" do
        expect(page).to have_css("a.button", text: "Done, go to the next step")
      end

      it "doesn't have the message that the census isn't ready" do
        expect(page).not_to have_content("The census is not ready yet")
      end
    end

    context "when don't select any permissions" do
      before do
        perform_enqueued_jobs do
          click_button "Save census"
        end
        sleep 1
      end

      it "has success message" do
        expect(page).to have_admin_callout("Successfully imported 3 items (0 errors)")
      end

      it "goes to the next step" do
        expect(page).to have_css("a.button", text: "Done, go to the next step")
      end

      it "doesn't have the message that the census isn't ready" do
        expect(page).not_to have_content("The census is not ready yet")
      end
    end
  end

  private

  def deletes_the_census
    click_link "Delete all census data"

    within ".confirm-content" do
      expect(page).to have_content("Are you sure you want to continue?")
    end

    within ".confirm-modal-footer" do
      click_link "OK"
    end

    expect(page).to have_content("Upload a CSV file")
  end

  def visit_census_page
    election

    relogin_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      click_link "Edit"
    end

    find("li.tabs-title a", text: "Census").click
  end

  def valid_census_file
    File.expand_path(File.join("..", "..", "..", "assets", "valid-census.csv"), __dir__)
  end
end
