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
      let!(:voter1) { create(:vocdoni_voter, election: election, token: "123456", email: "user_1@example.org") }
      let!(:voter2) { create(:vocdoni_voter, election: election, token: "123abc", email: "user_2@example.org") }
      let!(:voter3) { create(:vocdoni_voter, election: election, token: "123abc", email: "user_3@example.org") }
      let!(:voter4) { create(:vocdoni_voter, election: election, token: "abcxyz", email: "user_4@example.org") }
      let!(:voter5) { create(:vocdoni_voter, election: election, token: "123abc", email: "user_5@example.org") }

      it "generates the credentials" do
        visit_census_page

        expect(page).to have_content("There are 5 records loaded in total")
        expect(page).to have_content("Current census data")
        expect(page).to have_content("Confirm the census data")

        click_button "Confirm the census data"

        expect(page).to have_content("The census data is uploaded and confirmed")
        expect(voter1.reload.wallet_address).to eq("0xFEA59AF4dD69C285f39CC6836DA2664f36A47A71")
        expect(voter2.reload.wallet_address).to eq("0xA0A46c789F1D86a0AA04Cd18E7965C726864B991")
        expect(voter3.reload.wallet_address).to eq("0x1A4d5529E04803054fC0338eA07083FD977cD115")
        expect(voter4.reload.wallet_address).to eq("0xBc8dB7502067bFCc44ccCA105dD4cdfabB8DDDfb")
        expect(voter5.reload.wallet_address).to eq("0x183f5bC91423354F7351dFC4a877a8AC75910CA1")
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
      click_link "Edit"
    end

    find("li.tabs-title a", text: "Census").click
  end

  def valid_census_file
    File.expand_path(File.join("..", "..", "..", "assets", "valid-census.csv"), __dir__)
  end
end
