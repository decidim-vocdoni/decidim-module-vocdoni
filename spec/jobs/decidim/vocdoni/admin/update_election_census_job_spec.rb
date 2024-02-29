# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Vocdoni::Admin::UpdateElectionCensusJob, type: :job do
  subject { described_class.perform_later(election.id, non_voter_ids, user.id) }

  let!(:election) { create(:vocdoni_election, :upcoming, :with_internal_census) }
  let(:user) { create(:user, :admin, :confirmed, organization: election.organization) }
  let!(:non_voters) { create_list(:user, 2, :confirmed, organization: election.organization) }
  let(:non_voter_ids) { non_voters.map(&:id) }

  before do
    non_voters.each do |nv|
      create(:vocdoni_voter, email: nv.email, election: election, wallet_address: nil, in_vocdoni_census: false)
    end

    allow(Decidim::Vocdoni::VoterService).to receive(:verify_and_insert).and_call_original
    allow(Decidim::Vocdoni::Admin::CreateVoterWalletsJob).to receive(:perform_now).and_call_original
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Decidim::Vocdoni::CensusUpdaterService).to receive(:update_census).and_return(true)
    # rubocop:enable RSpec/AnyInstance
  end

  describe "#perform" do
    let(:voters) { Decidim::Vocdoni::Voter.where(decidim_vocdoni_election_id: election.id) }

    it "updates wallet_address and in_vocdoni_census for Voters" do
      perform_enqueued_jobs { subject }

      voters.each do |voter|
        expect(voter.wallet_address).not_to be_nil
        expect(voter.in_vocdoni_census).to be true
      end
    end
  end
end
