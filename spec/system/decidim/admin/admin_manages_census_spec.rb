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

      expect(page).to have_content("Upload a new census")

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

        expect(page).to have_content("There are 5 records loaded in total")
        expect(page).to have_content("Current census data")
        expect(page).to have_content("Confirm the census data")

        click_button "Confirm the census data"

        expect(page).to have_content("The census data is uploaded and confirmed")
        expect(voter1.reload.wallet_address).to eq("0x50a688dbB767bD3ebd93022B87B2c19cE936bd93")
        expect(voter2.reload.wallet_address).to eq("0xA7e77F2706e6981002c15B5E8d441fBC8EA0fC9E")
        expect(voter3.reload.wallet_address).to eq("0xd2d6C90A4f4daed530D9b0B7Aae3271c73610AA7")
        expect(voter4.reload.wallet_address).to eq("0x8a186ec407591ef7c5D000C81D99f7E174648a27")
        expect(voter5.reload.wallet_address).to eq("0x75bA570b7135216f14B9A4C77558159793367fFb")
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
      page.find(".action-icon--manage-census").click
    end
  end

  def valid_census_file
    File.expand_path(File.join("..", "..", "..", "assets", "valid-census.csv"), __dir__)
  end
end
