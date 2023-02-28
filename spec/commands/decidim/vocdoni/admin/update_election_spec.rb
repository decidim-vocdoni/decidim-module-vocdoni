# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::UpdateElection do
  subject { described_class.new(form, election) }

  let(:election) { create :vocdoni_election }
  let(:organization) { election.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      title: { en: "title" },
      description: { en: "description" },
      stream_uri: "https://example.org/stream",
      start_time: start_time,
      end_time: end_time,
      attachment: attachment_params,
      photos: current_photos,
      add_photos: uploaded_photos,
      auto_start: true,
      interruptible: true,
      dynamic_census: false,
      secret_until_the_end: false,
      anonymous: false
    )
  end
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 2.days.from_now }
  let(:current_photos) { [] }
  let(:uploaded_photos) { [] }
  let(:attachment_params) { nil }
  let(:invalid) { false }

  it "updates the election" do
    subject.call
    expect(translated(election.title)).to eq "title"
    expect(translated(election.description)).to eq "description"
    expect(election.start_time).to be_within(1.second).of start_time
    expect(election.end_time).to be_within(1.second).of end_time
    expect(election.election_type.fetch("auto_start")).to be_truthy
    expect(election.election_type.fetch("interruptible")).to be_truthy
    expect(election.election_type.fetch("dynamic_census")).to be_falsy
    expect(election.election_type.fetch("secret_until_the_end")).to be_falsy
    expect(election.election_type.fetch("anonymous")).to be_falsy
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:update!)
      .with(election, user, hash_including(:title, :description, :start_time, :end_time), visibility: "all")
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "update"
  end

  context "with attachment" do
    it_behaves_like "admin manages resource gallery" do
      let(:command) { described_class.new(form, election) }
      let(:resource_class) { Decidim::Vocdoni::Election }
      let(:resource) { election }
    end
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
