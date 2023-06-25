# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::ManualStartElection do
  subject { described_class.new(election) }

  let(:election) { create :vocdoni_election, manual_start: manual_start, start_time: start_time, end_time: end_time }
  let(:organization) { election.component.organization }

  let(:start_time) { nil }
  let(:end_time) { 2.days.from_now }
  let(:manual_start) { true }

  describe "call" do
    it "starts the election" do
      expect { subject.call }.to change { election.reload.status }.to("vote")
    end

    it "broadcasts :ok with the election" do
      expect { subject.call }.to broadcast(:ok, election)
    end
  end
end
