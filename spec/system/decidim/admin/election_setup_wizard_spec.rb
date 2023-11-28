# frozen_string_literal: true

require "spec_helper"

describe "Election setup wizard", :slow, type: :system do
  let(:manifest_name) { :vocdoni }
  let(:current_component) { create :vocdoni_component }
  let(:election_title) { "My election" }
  let(:election_description) { "My election description" }
  let(:edit_title) { "Edit election \"#{election_title}\"" }

  include_context "when managing a component as an admin"

  shared_examples "has setup wizard tabs" do
    it "displays all wizard tabs" do
      expect(page).to have_content("Basic info")
      expect(page).to have_content("Questions")
      expect(page).to have_content("Census")
      expect(page).to have_content("Calendar and results")
      expect(page).to have_content("Publish")
    end
  end

  describe "create a new election" do
    before do
      visit_component_admin
      click_link "New election"
    end

    it_behaves_like "has setup wizard tabs"

    describe "basic info" do
      it "has title" do
        expect(page).to have_content("New election")
      end

      it "has an active tab" do
        expect(page).to have_css("li.tabs-title.is-active a", text: "Basic info")
      end

      it "has form fields" do
        expect(page).to have_content("Title")
        expect(page).to have_content("Description")
        expect(page).to have_content("Add an image gallery")
        expect(page).to have_content("Video stream link")
      end

      context "when the form is not valid" do
        before do
          click_button "Save and go to the next step"
        end

        it "shows errors" do
          expect(page).to have_content("can't be blank", count: 2)
        end
      end

      context "when the form is valid" do
        before do
          fill_basic_info
        end

        it "goes to the next step" do
          expect(page).to have_content("New question")
        end
      end
    end

    describe "questions" do
      before do
        fill_basic_info
      end

      it "has title" do
        expect(page).to have_content(edit_title)
      end

      it "has an active tab" do
        expect(page).to have_css("li.tabs-title.is-active a", text: "Questions")
      end

      it "can edit previous step" do
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Basic info")
      end

      context "when creates a new question with 2 answers" do
        before do
          fill_question
          click_link "Manage answers"
          fill_answer_first
          fill_answer_second
          click_link "Done, go to the next step"
        end

        it "goes to the next step" do
          expect(page).to have_content("Upload a new census")
          expect(page).not_to have_content("Questions must have at least two answers in order to go to the next step.")
        end
      end

      context "when creates a new question with 1 answer" do
        before do
          fill_question
          click_link "Manage answers"
          fill_answer_first
          click_link "Back to questions"
        end

        it "doesn't go to the next step" do
          expect(page).not_to have_css("a.button", text: "Done, go to the next step")
          expect(page).to have_css("li.tabs-title a.disabled", text: "Census")
          expect(page).to have_content("Questions must have at least two answers in order to go to the next step.")
        end
      end
    end

    describe "census" do
      before do
        fill_basic_info
        fill_question
        click_link "Manage answers"
        fill_answer_first
        fill_answer_second
        click_link "Done, go to the next step"
      end

      it "has title" do
        expect(page).to have_content(edit_title)
      end

      it "has an active tab" do
        expect(page).to have_css("li.tabs-title.is-active a", text: "Census")
      end

      it "has form fields" do
        expect(page).to have_content("Upload a new census")
      end

      it "can edit previous steps" do
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Basic info")
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Questions")
      end

      context "when the form is not valid" do
        before do
          click_button "Upload file"
        end

        it "shows errors" do
          expect(page).to have_content("error in this field")
        end

        it "doesn't go to the next step" do
          expect(page).not_to have_css("a.button", text: "Done, go to the next step")
          expect(page).to have_css("li.tabs-title a.disabled", text: "Calendar and results")
        end
      end

      context "when the form is valid" do
        before do
          upload_census
        end

        it "goes to the next step" do
          expect(page).to have_content("Start time")
        end
      end
    end

    describe "calendar and results" do
      before do
        fill_basic_info
        fill_question
        click_link "Manage answers"
        fill_answer_first
        fill_answer_second
        click_link "Done, go to the next step"
        upload_census
      end

      it "has title" do
        expect(page).to have_content(edit_title)
      end

      it "has an active tab" do
        expect(page).to have_css("li.tabs-title.is-active a", text: "Calendar and results")
      end

      it "has form fields" do
        expect(page).to have_content("Start time")
        expect(page).to have_content("End time")
      end

      it "can edit previous steps" do
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Basic info")
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Questions")
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Census")
      end

      context "when the form is not valid" do
        before do
          click_button "Save and go to the next step"
        end

        it "shows errors" do
          expect(page).to have_content("error in this field", count: 2)
        end
      end

      context "when the form is valid" do
        before do
          fill_calendar_and_results
        end

        it "goes to the next step" do
          expect(page).to have_content("To setup the election you must publish it first")
        end
      end

      context "when selecting manual start" do
        before do
          check "Manual start"
        end

        it "disables the start time field" do
          expect(page).to have_field("election_calendar_start_time", disabled: true, class: "text-muted")
        end
      end
    end

    describe "publish" do
      before do
        fill_basic_info
        fill_question
        click_link "Manage answers"
        fill_answer_first
        fill_answer_second
        click_link "Done, go to the next step"
        upload_census
        fill_calendar_and_results
      end

      it "has title" do
        expect(page).to have_content("Publish election \"#{election_title}\"")
      end

      it "has an active tab" do
        expect(page).to have_css("li.tabs-title.is-active a", text: "Publish")
      end

      it "can edit previous steps" do
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Basic info")
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Questions")
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Census")
        expect(page).not_to have_css("li.tabs-title a.disabled", text: "Calendar and results")
      end

      context "when click the publish button" do
        before do
          find("a.hollow", text: "Publish").click
          click_link "Done, go to the next step"
          click_link "Create"
        end

        it "redirects to the steps dashboard" do
          expect(page).to have_content("Steps dashboard")
        end
      end
    end
  end

  describe "edit elections" do
    let!(:election) { create :vocdoni_election, component: current_component }

    before do
      visit_component_admin
      click_link "Edit"
    end

    it "has edit title" do
      expect(page).to have_content("Edit election \"#{translated(election.title)}\"")
    end

    it_behaves_like "has setup wizard tabs"
  end

  private

  def fill_basic_info
    fill_in "election_title_#{I18n.locale}", with: election_title
    fill_in_i18n_editor :election_description, "#election-description-tabs", en: election_description
    click_button "Save and go to the next step"
  end

  def fill_question
    click_link "New question"
    fill_in "question_title_#{I18n.locale}", with: "My question"
    fill_in "question_description_#{I18n.locale}", with: "My question description"
    click_button "Create question"
  end

  def fill_answer_first
    click_link "New answer"
    fill_in "answer_title_#{I18n.locale}", with: "My answer"
    fill_in_i18n_editor :answer_description, "#answer-description-tabs", en: "My answer description"
    click_button "Create answer"
  end

  def fill_answer_second
    click_link "New answer"
    fill_in "answer_title_#{I18n.locale}", with: "My second answer"
    fill_in_i18n_editor :answer_description, "#answer-description-tabs", en: "My answer description"
    click_button "Create answer"
    click_link "Back to questions"
  end

  def upload_census
    attach_file("census_data[file]", valid_census_file)
    # wallets are generated asynchronously
    perform_enqueued_jobs do
      click_button "Upload file"
    end
    click_link "Done, go to the next step"
  end

  def valid_census_file
    File.expand_path(File.join("..", "..", "..", "assets", "valid-census.csv"), __dir__)
  end

  def fill_calendar_and_results
    fill_in "election_calendar_start_time", with: 12.minutes.from_now.strftime("%d/%m/%Y %H:%M")
    send_keys(:enter)
    fill_in "election_calendar_end_time", with: 12.days.from_now.strftime("%d/%m/%Y %H:%M")
    send_keys(:enter)
    click_button "Save and go to the next step"
  end
end
