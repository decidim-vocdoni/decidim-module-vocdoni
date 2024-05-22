# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::Vocdoni::CensusUpdaterService do
  let(:election) { create(:vocdoni_election, :upcoming, :with_internal_census) }
  let(:current_user) { create(:user, :admin, :confirmed, organization: election.organization) }
  let(:non_voter_ids) { create_list(:user, 2, :confirmed, organization: election.organization).map(&:id) }
  let(:service) { described_class.new(election, current_user.id, non_voter_ids) }

  describe "#update_census" do
    context "when election has an internal census" do
      before do
        allow(election).to receive(:internal_census?).and_return(true)
        allow(election.census_status).to receive(:all_wallets).and_return(%w(wallet1 wallet2))
      end

      it "updates the census successfully" do
        fake_response = { "success" => true, "timestamp" => Time.zone.now }.to_json

        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:updateCensus).and_return(fake_response)
        # rubocop:enable RSpec/AnyInstance

        expect { service.update_census }.to change { election.reload.census_last_updated_at }.from(nil)
      end

      it "deletes technical voter successfully when it does not exist" do
        fake_response = { "success" => true, "timestamp" => Time.zone.now }.to_json

        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:updateCensus).and_return(fake_response)
        # rubocop:enable RSpec/AnyInstance

        expect(Rails.logger).not_to receive(:info).with(/Technical voter .* deleted successfully./)
        expect { service.update_census }.not_to raise_error
        expect(Decidim::Vocdoni::Voter.where(email: election.technical_voter_email, election:)).not_to exist
      end

      it "logs an error if the SDK response is unsuccessful" do
        fake_response = { "success" => false, "error" => "Some error" }.to_json
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:updateCensus).and_return(fake_response)
        # rubocop:enable RSpec/AnyInstance

        expect(Rails.logger).to receive(:error).with("Error updating census: Some error")
        service.update_census
      end
    end

    context "when election does not have an internal census" do
      before do
        allow(election).to receive(:internal_census?).and_return(false)
      end

      it "does not update the census" do
        expect(election.census_status).not_to receive(:all_wallets)
        # rubocop:disable RSpec/AnyInstance
        expect_any_instance_of(Decidim::Vocdoni::Sdk).not_to receive(:updateCensus)
        # rubocop:enable RSpec/AnyInstance

        service.update_census
      end
    end
  end
end
