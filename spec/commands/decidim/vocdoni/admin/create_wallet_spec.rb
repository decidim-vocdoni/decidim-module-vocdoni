# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::CreateWallet do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      private_key: private_key,
      current_organization: organization,
      current_user: user
    )
  end
  let(:invalid) { false }
  let(:private_key) { "0x12345678" }
  let(:wallet) { Decidim::Vocdoni::Wallet.last }

  it "creates the wallet" do
    expect { subject.call }.to change(Decidim::Vocdoni::Wallet, :count).by(1)
  end

  it "stores the given data" do
    subject.call
    expect(wallet.private_key).to eq "0x12345678"
    expect(wallet.organization).to eq organization
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

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
