# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Wallet do
  subject(:wallet) { build(:vocdoni_wallet) }

  it "is valid with valid attributes" do
    expect(wallet).to be_valid
  end

  it "belongs to an organization" do
    expect(Decidim::Vocdoni::Wallet.reflect_on_association(:organization).macro).to eq(:belongs_to)
  end

  it "is not valid without a private key" do
    wallet.private_key = nil
    expect(wallet).not_to be_valid
  end

  context "when private key is not unique" do
    let!(:existing_wallet) { create(:vocdoni_wallet) }
    let(:duplicate_wallet) { build(:vocdoni_wallet, private_key: existing_wallet.private_key) }

    it "does not allow saving" do
      expect(duplicate_wallet).not_to be_valid
      expect(duplicate_wallet.errors[:private_key]).to include("has already been taken")
    end
  end
end
