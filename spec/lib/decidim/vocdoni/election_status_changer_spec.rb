# frozen_string_literal: true

require "spec_helper"
require "decidim/vocdoni/election_status_changer"

describe Decidim::Vocdoni::ElectionStatusChanger do
  subject { described_class.new }

  let!(:new_election) { create(:vocdoni_election, status: status) }
  let!(:upcoming_election) { create(:vocdoni_election, :upcoming, start_mode, status: status) }
  let!(:ongoing_election) { create(:vocdoni_election, :ongoing, start_mode, start_time: 1.minute.ago, status: status) }
  let!(:finished_election) { create(:vocdoni_election, :finished, start_mode, end_time: 1.minute.ago, status: status) }
  let(:status) { nil }
  let(:start_mode) { :auto_start }

  describe "run" do
    before do
      subject.run
    end

    context "when the elections don't have any status" do
      it "don't change any status" do
        expect(new_election.reload.status).to be_nil
        expect(upcoming_election.reload.status).to be_nil
        expect(ongoing_election.reload.status).to be_nil
        expect(finished_election.reload.status).to be_nil
      end
    end

    context "with an upcoming election" do
      let(:status) { "created" }

      it "keeps the same status" do
        expect(upcoming_election.reload.status).to eq status
      end
    end

    context "with an ongoing election" do
      let(:status) { "created" }

      context "with created status" do
        it "changes the status" do
          expect(ongoing_election.reload.status).to eq "vote"
        end
      end

      context "with vote status" do
        let(:status) { "vote" }

        it "keeps the same status" do
          expect(ongoing_election.reload.status).to eq status
        end
      end

      context "when manual mode" do
        let(:start_mode) { :manual_start }

        it "keeps the same status" do
          expect(upcoming_election.reload.status).to eq status
        end
      end
    end

    context "with an finished election" do
      let(:status) { "created" }

      context "with created status" do
        it "changes the status" do
          expect(finished_election.reload.status).to eq "vote_ended"
        end
      end

      context "with vote status" do
        let(:status) { "vote" }

        it "changes the status" do
          expect(finished_election.reload.status).to eq "vote_ended"
        end

        context "when manual mode" do
          let(:start_mode) { :manual_start }

          it "changes the status" do
            expect(finished_election.reload.status).to eq "vote_ended"
          end
        end
      end

      context "with vote_ended status" do
        let(:status) { "vote_ended" }

        it "keeps the same status" do
          expect(finished_election.reload.status).to eq status
        end
      end
    end
  end
end
