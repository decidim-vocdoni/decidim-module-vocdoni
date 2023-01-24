# frozen_string_literal: true

require "spec_helper"

describe "Admin manages census", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let(:election) { create :election, :ready_for_setup, component: current_component, title: { en: "English title" } }

  include_context "when managing a component as an admin"

  context "when uploading the census CSV" do
    it "has the form" do
      visit_census_page

      expect(page).to have_content("Must be a file in CSV format with only two columns")
    end

    context "and the census is valid" do
      it "uploads the census" do
        visit_census_page

        attach_file("census_data[file]", valid_census_file)
        click_button "Upload file"

        expect(page).to have_content("Successfully imported 1 items")
        expect(page).to have_content("There are 1 records loaded in total")
      end
    end
  end

  context "when deleting the census CSV" do
    let!(:csv_datum) { create(:csv_datum, election: election) }

    it "deletes it" do
      visit_census_page

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
  end

  private

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
