# frozen_string_literal: true

require "spec_helper"

describe "Admin manages census", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let(:election) { create :election, :upcoming, :published, :complete, component: current_component, title: { en: "English title" } }

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
      let!(:voters) { create_list(:vocdoni_voter, 5, election: election) }

      it "generates the credentials" do
        visit_census_page

        expect(page).to have_content("2. Generate credentials for the participants")

        click_button "Generate credentials"

        expect(page).to have_content("The census data is uploaded, the credentials generated, and its ready to setup")
        expect(voters.map(&:reload).pluck(:wallet_address)).to all(start_with("0x"))
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
