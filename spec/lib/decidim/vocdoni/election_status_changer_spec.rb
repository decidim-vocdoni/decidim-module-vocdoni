# frozen_string_literal: true

require "spec_helper"
require "decidim/vocdoni/election_status_changer"

describe Decidim::Vocdoni::ElectionStatusChanger do
  subject { described_class.new }

  describe "run" do
    let!(:upcoming_election) { create(:vocdoni_election, :upcoming) }
    let!(:ongoing_election) { create(:vocdoni_election, :ongoing) }
    let!(:finished_election) { create(:vocdoni_election, :finished, status: "vote_ended") }

    # A finished election that hasn't changed the status yet
    let!(:finished_election_2) { create(:vocdoni_election, :finished, status: "vote") }

    before { subject.run }

    it "works as expected" do
      expect(upcoming_election.reload.status).to be_nil
      expect(ongoing_election.reload.status).to eq "vote"
      expect(finished_election.reload.status).to eq "vote_ended"
      expect(finished_election_2.reload.status).to eq "vote_ended"
    end
  end
end
