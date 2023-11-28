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

      expect(page).to have_content("Upload a new census")

      attach_file("census_data[file]", valid_census_file)
      perform_enqueued_jobs do
        click_button "Upload file"
      end

      expect(page).to have_content("Successfully imported 2 items")
      expect(page).to have_content("There are 2 records loaded in total")

      expect(voter1.wallet_address).to eq("0x798F2E3A2406B27aC6E89F3aef02efB2005A724d")
      expect(voter2.wallet_address).to eq("0xEb41E436E768b814102902ABF1fd155e007f94D3")
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

        # simulate the percentage of completion
        wallet = Decidim::Vocdoni::Sdk.new(organization, election).deterministicWallet([voter1.email, voter1.token])["address"]
        voter1.update(wallet_address: wallet)
        voter1.reload
        sleep 1

        expect(page).to have_content("Completed 20% of 5 total records")
        expect(voter1.reload.wallet_address).to eq("0x394DFfEfba5DC574E4c52e64e6c09B8442f96948")
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

  private

  def deletes_the_census
    click_link "Delete all census data"

    within ".confirm-content" do
      expect(page).to have_content("Are you sure you want to continue?")
    end

    within ".confirm-modal-footer" do
      click_link "OK"
    end

    expect(page).to have_content("Upload a new census")
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
