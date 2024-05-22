# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::ElectionCell, type: :cell do
  controller Decidim::Vocdoni::ElectionsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/vocdoni/election", model) }
  let!(:election) { create(:vocdoni_election, :published, :ongoing) }
  let!(:current_user) { create(:user, :confirmed, organization: model.participatory_space.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering an election" do
    let(:model) { election }

    it "renders the card" do
      expect(subject).to have_css(".card__grid")
    end

    it "renders the title and text" do
      expect(subject).to have_css(".card__grid-text")
    end
  end
end
