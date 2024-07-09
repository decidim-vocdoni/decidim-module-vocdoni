# frozen_string_literal: true

require "spec_helper"

describe "Admin manages census", :slow do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create(:vocdoni_component) }
  let(:election) { create(:vocdoni_election, :upcoming, :published, :complete, component: current_component, title: { en: "English title" }) }
  let(:valid_census_file) { file_fixture("valid-census.csv") }

  before do
    allow(Rails.application).to receive(:secret_key_base).and_return("a-secret-key-base")
  end

  include_context "when managing a component as an admin"

  context "when there isn't any census" do
    let(:voters) do
      [
        Decidim::Vocdoni::Voter.find_by(email: "john@example.org"),
        Decidim::Vocdoni::Voter.find_by(email: "alice@example.org")
      ]
    end

    it "uploads the census" do
      visit_census_page

      expect(page).to have_content("Upload a CSV file")

      attach_file("census_data[file]", valid_census_file)
      perform_enqueued_jobs do
        click_link_or_button "Upload file"
      end

      expect(page).to have_content("Successfully imported 2 items")
      expect(page).to have_content("There are 2 records loaded in total")

      expect(voters[0].wallet_address).to eq("0x0b9eA6587591d888f0b3a2D67f3d416246BB9304")
      expect(voters[1].wallet_address).to eq("0x5D38b06B50412294532b9A2C0127AD1455Af7934")
    end
  end

  context "when there's already a census" do
    context "without the credentials" do
      let!(:voters) do
        [
          { token: "123456", email: "user_1@example.org" },
          { token: "123abc", email: "user_2@example.org" },
          { token: "123abc", email: "user_3@example.org" },
          { token: "abcxyz", email: "user_4@example.org" },
          { token: "123abc", email: "user_5@example.org" }
        ].map do |voter_data|
          create(:vocdoni_voter, election:, token: voter_data[:token], email: voter_data[:email])
        end
      end

      it "has progress indicator of the generation of the credentials" do
        visit_census_page

        expect(page).to have_content("There are 5 records loaded in total")
        expect(page).to have_content("Current census data")
        expect(page).to have_content("Completed 0% of 5 total records")

        # Simulates the percentage of completion
        wallet = Decidim::Vocdoni::Sdk.new(organization, election).deterministicWallet([voters[0].email, voters[0].token])["address"]
        voters[0].update(wallet_address: wallet)
        voters[0].reload
        sleep 1

        expect(page).to have_content("Completed 20% of 5 total records")
        expect(voters[0].reload.wallet_address).to eq("0xFEA59AF4dD69C285f39CC6836DA2664f36A47A71")
        expect(voters[1].reload.wallet_address).to be_nil
      end

      describe "and we want to delete it" do
        it "deletes it" do
          visit_census_page

          deletes_the_census
          expect(page).to have_content("Upload a CSV file")
        end
      end
    end

    context "with the credentials" do
      let!(:voters) { create_list(:vocdoni_voter, 5, :with_wallet, election:) }

      it "doesn't have any form" do
        visit_census_page

        expect(page).to have_no_content("Upload a new census")
        expect(page).to have_no_content("Confirm the census data")
      end

      context "and we want to delete it" do
        it "deletes it" do
          visit_census_page

          deletes_the_census
          expect(page).to have_content("Upload a CSV file")
        end
      end
    end
  end

  describe "internal census" do
    let!(:authorization_handler_name) { "dummy_authorization_handler" }
    let!(:id_document_handler_name) { "another_dummy_authorization_handler" }
    let(:translated_authorization_handler_name) { I18n.t("decidim.authorization_handlers.#{authorization_handler_name}.name") }
    let(:translated_id_document_handler_name) { I18n.t("decidim.authorization_handlers.#{id_document_handler_name}.name") }
    let!(:organization) { create(:organization, available_authorizations:) }
    let!(:available_authorizations) { [authorization_handler_name, id_document_handler_name] }
    let(:authorizations_count) { organization.available_authorizations.count }
    let(:authorizations_checkboxes) { find_all("input[type='checkbox'][name='census_permissions[verification_types][]']") }
    let!(:user_with_authorizations) { create(:user, :admin, :confirmed, organization:) }
    let!(:user_without_authorizations) { create(:user, :admin, :confirmed, organization:) }
    let!(:dummy_authorization) { create(:authorization, user: user_with_authorizations, name: id_document_handler_name) }

    before do
      visit_census_page
      choose("permissions_radio_button")
    end

    it "has Decidim permissions content" do
      expect(page).to have_content("Internal (registered participants")
      expect(authorizations_checkboxes.count).to eq(authorizations_count)
    end

    it "has warning content for the internal census" do
      expect(page).to have_content("The census is not ready yet. You need save it to proceed.")
    end

    context "when selected any permission" do
      before do
        check(translated_id_document_handler_name)
        perform_enqueued_jobs do
          click_link_or_button "Save census"
        end
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

    context "when admin selects a few permissions" do
      before do
        check(translated_authorization_handler_name)
        check(translated_id_document_handler_name)
        perform_enqueued_jobs do
          click_link_or_button "Save census"
        end
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
        expect(page).to have_no_content("The census is not ready yet")
      end
    end

    context "when admin doesn't select any permissions" do
      before do
        perform_enqueued_jobs do
          click_link_or_button "Save census"
        end
      end

      it "has success message" do
        expect(page).to have_admin_callout("Successfully imported 3 items (0 errors)")
      end

      it "goes to the next step" do
        expect(page).to have_css("a.button", text: "Done, go to the next step")
      end

      it "doesn't have the message that the census isn't ready" do
        expect(page).to have_no_content("The census is not ready yet")
      end
    end
  end

  private

  def deletes_the_census
    click_link_or_button "Delete all census data"

    within "#confirm-modal-content" do
      expect(page).to have_content("Are you sure you want to continue?")
      click_link_or_button "OK"
    end
  end

  def visit_census_page
    election

    relogin_as user, scope: :user
    visit_component_admin

    within "tr", text: translated(election.title) do
      click_link_or_button "Edit"
    end

    find("li.tabs-title a", text: "Census").click
  end
end
