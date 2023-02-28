# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::UpdateElectionStatus do
  subject { described_class.new(form) }

  let(:election) { create :vocdoni_election }
  let(:organization) { election.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      status: "paused",
      election: election
    )
  end
  let(:invalid) { false }

  it "updates the election" do
    subject.call
    expect(election.status).to eq "paused"
  end

  it "traces the action", versioning: true do
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
end
