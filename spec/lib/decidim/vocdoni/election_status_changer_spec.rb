# frozen_string_literal: true

require "spec_helper"
require "decidim/vocdoni/election_status_changer"

describe Decidim::Vocdoni::ElectionStatusChanger do
  subject { described_class.new }

  describe "run" do
    let(:new_election) { create(:vocdoni_election) }
    let(:upcoming_election) { create(:vocdoni_election, :upcoming) }
    let(:ongoing_election) { create(:vocdoni_election, :ongoing) }
    let(:finished_election) { create(:vocdoni_election, :finished) }

    before do
      # Call all the factories first so they're actually created before
      # the class is run
      new_election
      upcoming_election
      ongoing_election
      finished_election

      subject.run
    end

    context "when the elections don't have any status" do
      let(:new_election) { create(:vocdoni_election) }
      let(:upcoming_election) { create(:vocdoni_election, :upcoming) }
      let(:ongoing_election) { create(:vocdoni_election, :ongoing) }
      let(:finished_election) { create(:vocdoni_election, :finished) }

      it "don't change any status" do
        expect(new_election.reload.status).to be_nil
        expect(upcoming_election.reload.status).to be_nil
        expect(ongoing_election.reload.status).to be_nil
        expect(finished_election.reload.status).to be_nil
      end
    end

    context "with an upcoming election" do
      let(:upcoming_election) { create(:vocdoni_election, :upcoming, status: "created") }

      it "keeps the same status" do
        expect(upcoming_election.reload.status).to eq "created"
      end
    end

    context "with an ongoing election" do
      context "with created status" do
        let(:ongoing_election) { create(:vocdoni_election, :ongoing, status: "created") }

        it "changes the status" do
          expect(ongoing_election.reload.status).to eq "vote"
        end
      end

      context "with vote status" do
        let(:ongoing_election) { create(:vocdoni_election, :ongoing, status: "vote") }

        it "keeps the same status" do
          expect(ongoing_election.reload.status).to eq "vote"
        end
      end
    end

    context "with an finished election" do
      context "with created status" do
        let(:finished_election) { create(:vocdoni_election, :finished, status: "created") }

        it "changes the status" do
          expect(finished_election.reload.status).to eq "vote_ended"
        end
      end

      context "with vote status" do
        let(:finished_election) { create(:vocdoni_election, :finished, status: "vote") }

        it "changes the status" do
          expect(finished_election.reload.status).to eq "vote_ended"
        end
      end

      context "with vote_ended status" do
        let(:finished_election) { create(:vocdoni_election, :finished, status: "vote_ended") }

        it "keeps the same status" do
          expect(finished_election.reload.status).to eq "vote_ended"
        end
      end
    end
  end
end
