# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::WalletForm do
  subject { described_class.from_params(attributes) }

  let(:private_key) { Faker::Blockchain::Ethereum.address }
  let(:attributes) do
    {
      private_key: private_key
    }
  end

  it { is_expected.to be_valid }

  describe "when private_key is missing" do
    let(:private_key) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when private_key doesn't have the correct length" do
    let(:private_key) { "0x123456789" }

    it { is_expected.not_to be_valid }
  end

  describe "when private_key doesn't start with 0x" do
    let(:private_key) { "12c6b8eb62f46d0863726410389d88b80be5d1e33672d841eaf2c7e395386fae53" }

    it { is_expected.not_to be_valid }
  end
end
