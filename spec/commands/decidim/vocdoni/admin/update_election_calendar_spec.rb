# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::UpdateElectionCalendar do
  subject { described_class.new(form, election) }

  let(:election) { create(:vocdoni_election) }
  let(:organization) { election.component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      start_time:,
      end_time:,
      manual_start:,
      interruptible: true,
      dynamic_census: false,
      result_type:,
      anonymous: false
    )
  end
  let(:result_type) { "real_time" }
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 2.days.from_now }
  let(:manual_start) { false }
  let(:invalid) { false }

  it "updates the election" do
    subject.call

    expect(election.manual_start?).to be(false)
    expect(election.start_time).to be_within(1.second).of start_time
    expect(election.end_time).to be_within(1.second).of end_time
    expect(election.election_type.fetch("auto_start")).to be_truthy
    expect(election.election_type.fetch("interruptible")).to be_truthy
    expect(election.election_type.fetch("dynamic_census")).to be_falsy
    expect(election.election_type.fetch("secret_until_the_end")).to eq(result_type == "after_voting")
    expect(election.election_type.fetch("anonymous")).to be_falsy
  end

  it "traces the action", :versioning do
    expect(Decidim.traceability)
      .to receive(:update!).with(election, user, hash_including(:start_time, :end_time, { election_type: { auto_start: true, anonymous: false, dynamic_census: false, interruptible: true, secret_until_the_end: (result_type == "after_voting") } }), visibility: "all").and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "update"
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
