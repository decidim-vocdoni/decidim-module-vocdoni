# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::ElectionGCell, type: :cell do
  controller Decidim::Vocdoni::ElectionsController

  subject { cell_html }

  let(:my_cell) { cell("decidim/vocdoni/election_g", election, context: { show_space: }) }
  let(:cell_html) { my_cell.call }
  let(:start_time) { 2.days.ago }
  let(:end_time) { 1.day.from_now }
  let!(:election) { create(:vocdoni_election, :ongoing, :auto_start, start_time:, end_time:) }
  let(:model) { election }
  let(:user) { create(:user, organization: election.participatory_space.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  it_behaves_like "has space in m-cell"

  context "when rendering" do
    let(:show_space) { false }

    it "renders the card" do
      expect(subject).to have_css(".card__grid")
    end

    it "renders the start and end time" do
      election_start = I18n.l(start_time.to_date, format: :decidim_short)
      election_end = I18n.l(end_time.to_date, format: :decidim_short)

      within ".card__grid-metadata" do
        expect(subject).to have_css("span", text: election_start)
        expect(subject).to have_css("span", text: election_end)
      end
    end

    it "renders the title and description" do
      description = strip_tags(translated(election.description, locale: :en))
      expect(subject).to have_css(".card__grid-text", text: translated(election.title))
      expect(subject).to have_css(".card__grid-text", text: description)
    end

    context "when election end less than 12 hours away" do
      let(:end_time) { 10.hours.from_now }

      it "renders remaining time callout" do
        expect(subject).to have_css(".flash__message", text: "remaining to vote")
      end
    end

    context "with attached image" do
      let(:image) { create(:attachment, :with_image, attached_to: election) }

      before do
        election.update!(attachments: [image])
      end

      it "shows the attached image" do
        expect(subject).to have_css(".card__grid-img")
      end
    end
  end
end
