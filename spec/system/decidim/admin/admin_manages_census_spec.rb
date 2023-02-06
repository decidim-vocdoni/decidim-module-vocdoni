# frozen_string_literal: true

require "spec_helper"

describe "Admin manages census", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let(:election) { create :vocdoni_election, :upcoming, :published, :complete, component: current_component, title: { en: "English title" } }

  include_context "when managing a component as an admin"

  context "when there isn't any census" do
    it "uploads the census" do
      visit_census_page

      expect(page).to have_content("1. Upload a new census")

      attach_file("census_data[file]", valid_census_file)
      click_button "Upload file"

      expect(page).to have_content("Successfully imported 1 items")
      expect(page).to have_content("There are 1 records loaded in total")
    end
  end

  context "when there's already a census" do
    context "without the credentials" do
      let!(:voter1) { create(:vocdoni_voter, election: election, born_at: "1923-01-01", email: "user_1@example.org") }
      let!(:voter2) { create(:vocdoni_voter, election: election, born_at: "1977-02-23", email: "user_2@example.org") }
      let!(:voter3) { create(:vocdoni_voter, election: election, born_at: "2000-02-23", email: "user_3@example.org") }
      let!(:voter4) { create(:vocdoni_voter, election: election, born_at: "1992-02-23", email: "user_4@example.org") }
      let!(:voter5) { create(:vocdoni_voter, election: election, born_at: "1954-02-23", email: "user_5@example.org") }

      it "generates the credentials" do
        visit_census_page

        expect(page).to have_content("2. Generate credentials for the participants")

        click_button "Generate credentials"

        expect(page).to have_content("The census data is uploaded, the credentials generated, and its ready to setup")
        expect(voter1.reload.wallet_address).to eq("0x1ff8B8E050eF497acD7f2286ba5427155E0e0D6d")
        expect(voter2.reload.wallet_address).to eq("0xb3395b02447f6Fb1eB60048477e9c80209b5b15f")
        expect(voter3.reload.wallet_address).to eq("0xe8e9c6167E9AF4A6f03628FCD67B083f2f79c9c5")
        expect(voter4.reload.wallet_address).to eq("0xf714bb3df89348b04D23BdB0fe9C334D25cd8452")
        expect(voter5.reload.wallet_address).to eq("0xb317c554C7C52FC9e0A39aE8A4bfc019287Bb6c8")
      end

      describe "and we want to delete it" do
        it "deletes it" do
          visit_census_page

          deletes_the_census
        end
      end
    end

    context "with the credentials" do
      let!(:voters) { create_list(:vocdoni_voter, 5, :with_credentials, election: election) }

      it "doesn't have any form" do
        visit_census_page

        expect(page).not_to have_content("1. Upload a new census")
        expect(page).not_to have_content("2. Generate credentials for the participants")
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

    expect(page).to have_content("All census data have been deleted")
    expect(page).to have_content("There are no census data")
  end

  def visit_census_page
    election

    relogin_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-census").click
    end
  end

  def valid_census_file
    File.expand_path(File.join("..", "..", "..", "assets", "valid-census.csv"), __dir__)
  end
end
