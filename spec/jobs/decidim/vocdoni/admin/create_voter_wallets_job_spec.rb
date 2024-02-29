# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Vocdoni::Admin::CreateVoterWalletsJob, type: :job do
  let!(:election) { create(:vocdoni_election, :upcoming, :with_internal_census) }
  let!(:voters) { create_list(:vocdoni_voter, 2, election: election, wallet_address: nil) }
  let(:election_id) { election.id }
  let(:fake_wallet_address) { "0x1234567890abcdef1234567890abcdef12345678" }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Decidim::Vocdoni::Admin::CreateVoterWalletsJob).to receive(:sdk).and_return(double("SDK", deterministicWallet: { "address" => fake_wallet_address }))
    # rubocop:enable RSpec/AnyInstance
  end

  it "assigns a wallet address to each Voter and saves them" do
    perform_enqueued_jobs do
      described_class.perform_later(election_id)
    end

    voters.each do |voter|
      expect(voter.reload.wallet_address).to eq(fake_wallet_address)
    end
  end
end
