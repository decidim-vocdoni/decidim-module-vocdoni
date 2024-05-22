# frozen_string_literal: true

require "spec_helper"

describe "Explore elections", :slow do # rubocop:disable RSpec/DescribeClass
  include_context "with a component"
  let(:manifest_name) { "vocdoni" }

  let(:elections_count) { 5 }
  let!(:elections) do
    create_list(:vocdoni_election, elections_count, :complete, :published, :auto_start, :ongoing, component:)
  end

  describe "index" do
    context "with only one election" do
      before do
        Decidim::Vocdoni::Election.destroy_all
      end

      let!(:single_elections) { create_list(:vocdoni_election, 1, :complete, :published, :auto_start, :ongoing, component:) }

      it "redirects to the only election" do
        visit_component

        expect(page).to have_content("Active voting until")
        expect(page).to have_no_content("All elections")
        expect(page).to have_content("These are the questions for this voting process")
      end
    end

    context "with many elections" do
      it "shows all elections for the given process" do
        visit_component
        expect(page).to have_css(".card__grid", count: elections_count)

        elections.each do |election|
          expect(page).to have_content(translated(election.title))
        end
      end
    end

    context "when no elections is given" do
      before do
        Decidim::Vocdoni::Election.destroy_all
      end

      it "shows the correct warning" do
        visit_component
        within "[data-announcement]" do
          expect(page).to have_content("any election scheduled")
        end
      end
    end
  end

  describe "show" do
    let(:elections_count) { 1 }
    let(:election) { elections.first }
    let(:question) { election.questions.first }
    let(:image) { create(:attachment, :with_image, attached_to: election) }

    before do
      election.update!(attachments: [image])
      visit resource_locator(election).path
    end

    it "shows all election info" do
      expect(page).to have_i18n_content(election.title)
      expect(page).to have_i18n_content(election.description)
      expect(page).to have_content(election.end_time.day)
    end

    it "shows accordion with questions and answers" do
      expect(page).to have_css(".election__accordion", count: election.questions.count)
      expect(page).to have_no_css(".election__accordion-panel")

      within ".election__accordion:first-child" do
        click_link_or_button translated(question.title)
        expect(page).to have_css("li", count: question.answers.count)
      end
    end

    context "with attached photos" do
      it "shows the image" do
        expect(page).to have_css("img[src*='city.jpeg']")
      end
    end
  end

  context "with results" do
    let(:election) { create(:vocdoni_election, :published, :results_published, component:) }
    let(:question) { create(:vocdoni_question, :with_votes, election:) }

    before do
      election.update!(questions: [question])
      visit resource_locator(election).path
    end

    it "shows result information" do
      expect(page).to have_i18n_content(question.title)
      expect(page).to have_content("Election results")
    end
  end
end
