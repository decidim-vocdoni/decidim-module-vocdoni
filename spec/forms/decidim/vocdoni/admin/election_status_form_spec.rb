# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::ElectionStatusForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:election) { create(:vocdoni_election, :ongoing) }
  let(:status) { "paused" }
  let(:context) do
    {
      election: election
    }
  end
  let(:attributes) do
    {
      status: status
    }
  end

  it { is_expected.to be_valid }

  describe "when the election isn't interruptible" do
    let(:election) { create(:vocdoni_election, :ongoing, election_type: { interruptible: false }) }

    it { is_expected.not_to be_valid }
  end

  describe "when the election's status doesn't exist" do
    let(:status) { "invalid" }

    it { is_expected.not_to be_valid }
  end
end
