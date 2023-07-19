# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::ElectionResultsRealtimeCell, type: :cell do
  controller Decidim::Vocdoni::ElectionsController

  subject { results_cell.call }

  let!(:component) { create(:vocdoni_component) }
  let(:results_cell) { cell("decidim/vocdoni/election_results_realtime", model) }
  let!(:current_user) { create(:user, :confirmed, organization: model.participatory_space.organization) }
  let(:model) { election }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    routes { Decidim::Vocdoni::Engine.routes }
  end

  context "when election is not secret until the end and not finished" do
    let!(:election) { create(:vocdoni_election, :published, :started, component: component, election_type: { "secret_until_the_end" => false }) }

    it "renders the cell" do
      expect(subject).to have_css(".realtime-results")
    end
  end

  context "when election is secret until the end" do
    let!(:election) { create(:vocdoni_election, :published, :started, election_type: { "secret_until_the_end" => true }) }

    it "does not render the cell" do
      expect(subject).not_to have_css(".realtime-results")
    end
  end

  context "when election is finished" do
    let!(:election) { create(:vocdoni_election, :published, :finished, election_type: { "secret_until_the_end" => false }) }

    it "does not render the cell" do
      expect(subject).not_to have_css(".realtime-results")
    end
  end
end
