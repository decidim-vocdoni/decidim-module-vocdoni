# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::UpdateElectionStatus do
  subject { described_class.new(form) }

  let(:election) { create(:vocdoni_election, status: :vote) }
  let(:organization) { election.component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      status: "paused",
      election:
    )
  end
  let(:invalid) { false }

  let(:election_metadata) do
    {
      "status" => status
    }
  end
  let(:status) { "ONGOING" }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:electionMetadata).and_return(election_metadata)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:pauseElection).and_return(true)
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:continueElection).and_return(true)
    # rubocop:enable RSpec/AnyInstance
  end

  it "updates the election" do
    subject.call
    expect(election.status).to eq "paused"
  end

  it "traces the action", :versioning do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:change_election_status, election, user)
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when out of sync with Vocdoni" do
    let(:status) { "ENDED" }

    it "is not valid" do
      expect { subject.call }.to broadcast(:status)
      expect(election.status).to eq "vote_ended"
    end
  end
end
