# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::CreateWallet do
  subject { described_class.new(user) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:wallet) { Decidim::Vocdoni::Wallet.find_by(organization: organization) }

  it "creates the wallet" do
    expect { subject.call }.to change(Decidim::Vocdoni::Wallet, :count).by(1)
  end

  it "stores the given data" do
    subject.call
    expect(wallet.private_key).to match(/\A0x[a-zA-Z0-9]*\z/)
    expect(wallet.organization).to eq organization
  end

  it "stores a deterministic wallet" do
    subject.call
    first = wallet.private_key
    wallet.destroy
    described_class.new(user).call
    expect(Decidim::Vocdoni::Wallet.find_by(organization: organization).private_key).to eq first
  end

  it "two equal private keys cannot be stored" do
    subject.call
    expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Vocdoni::Wallet,
        user,
        hash_including(:organization, :private_key)
      )
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "create"
  end

  context "when errors" do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:deterministicWallet).and_return("invalid")
      # rubocop:enable RSpec/AnyInstance
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "doesn't create the wallet" do
      expect { subject.call }.not_to change(Decidim::Vocdoni::Wallet, :count)
    end
  end
end
