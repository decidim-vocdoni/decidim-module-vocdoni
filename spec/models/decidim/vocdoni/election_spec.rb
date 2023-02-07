# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Election do
  subject(:election) { build :vocdoni_election }

  it { is_expected.to be_valid }

  include_examples "has component"
  include_examples "resourceable"
  include_examples "publicable" do
    let(:factory_name) { :vocdoni_election }
  end

  describe "check the log result" do
    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::Vocdoni::AdminLog::ElectionPresenter
    end
  end

  it { is_expected.not_to be_started }
  it { is_expected.not_to be_ongoing }
  it { is_expected.not_to be_finished }

  context "when it is ongoing" do
    subject(:election) { build :vocdoni_election, :ongoing }

    it { is_expected.to be_started }
    it { is_expected.to be_ongoing }
    it { is_expected.not_to be_finished }
  end

  context "when it is finished" do
    subject(:election) { build :vocdoni_election, :finished }

    it { is_expected.to be_started }
    it { is_expected.not_to be_ongoing }
    it { is_expected.to be_finished }
  end

  describe "start time checks" do
    subject(:election) { build(:vocdoni_election, start_time: start_time) }

    let(:start_time) { 40.minutes.from_now }

    it { is_expected.to be_minimum_minutes_before_start }

    context "when the election is about to start" do
      let(:start_time) { 5.minutes.from_now }

      it { is_expected.not_to be_minimum_minutes_before_start }
    end

    context "when the election is not near to start" do
      let(:start_time) { 10.days.from_now }

      it { is_expected.to be_minimum_minutes_before_start }
    end
  end

  describe "#explorer_vote_url" do
    subject(:election) { build :vocdoni_election, vocdoni_election_id: "12345"}

    it "returns the URL" do
      expect(subject.explorer_vote_url).to eq "https://dev.explorer.vote/processes/show/#/12345"
    end
  end
end
