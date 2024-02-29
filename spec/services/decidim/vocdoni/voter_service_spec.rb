# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    RSpec.describe VoterService do
      let!(:election) { create(:vocdoni_election, :upcoming, :with_internal_census) }
      let!(:non_voters) { create_list(:user, 2, :confirmed, organization: election.organization) }
      let(:non_voter_ids) { non_voters.map(&:id) }

      describe ".verify_and_insert" do
        before do
          VoterService.verify_and_insert(election, non_voter_ids)
        end

        it "creates Voter records for each non-voter" do
          expect(Voter.count).to eq(non_voter_ids.size)
        end

        it "assigns correct email and token to each Voter" do
          non_voters.each do |user|
            voter = Voter.find_by(email: user.email)
            expect(voter).not_to be_nil
            expect(voter.token).to start_with("#{user.email}-#{election.id}-")
          end
        end

        it "associates Voters with the correct election" do
          Voter.all.each do |voter|
            expect(voter.election).to eq(election)
          end
        end
      end
    end
  end
end
