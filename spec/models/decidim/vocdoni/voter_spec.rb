# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Voter do
  subject(:voter) { build :vocdoni_voter }

  let(:election) { create :vocdoni_election }

  describe "#validations" do
    it "is invalid without a valid email" do
      voter.email = "invalid_email"
      expect(voter).not_to be_valid
    end

    it "is invalid without a token" do
      voter.token = nil
      expect(voter).not_to be_valid
    end

    it "does not allow duplicate emails within the same election" do
      create(:vocdoni_voter, election: election, email: "user@example.com")
      new_voter = build(:vocdoni_voter, election: election, email: "user@example.com")
      expect(new_voter).not_to be_valid
    end
  end

  describe ".insert_all" do
    let(:values) do
      [
        %w(user1@example.org 123456),
        %w(user2@example.org abc xyz)
      ]
    end

    before do
      # rubocop:disable Rails/SkipsModelValidations
      Decidim::Vocdoni::Voter.insert_all(election, values)
      # rubocop:enable Rails/SkipsModelValidations
    end

    it "creates the voters" do
      voter1 = Decidim::Vocdoni::Voter.first
      expect(voter1.email).to eq "user1@example.org"
      expect(voter1.token).to eq "123456"
      expect(voter1.election).to eq election

      voter2 = Decidim::Vocdoni::Voter.second
      expect(voter2.email).to eq "user2@example.org"
      expect(voter2.token).to eq "abcxyz"
      expect(voter2.election).to eq election
    end

    context "when the email isn't lowercase" do
      let(:values) do
        [
          ["USER1@example.org", "123456"]
        ]
      end

      it "is normalized" do
        expect(Decidim::Vocdoni::Voter.first.email).to eq("user1@example.org")
      end
    end

    context "when the token isn't lowercase" do
      let(:values) do
        [
          ["USER1@example.org", "ABCXYZ"]
        ]
      end

      it "is normalized" do
        expect(Decidim::Vocdoni::Voter.first.token).to eq("abcxyz")
      end
    end
  end

  describe ".inside" do
    let!(:voter) { create(:vocdoni_voter, election: election) }

    it "returns voters for a specific election" do
      expect(Decidim::Vocdoni::Voter.inside(election)).to include(voter)
    end
  end

  describe ".search_user_email" do
    let!(:voter) { create(:vocdoni_voter, election: election, email: "user@example.com") }

    it "returns the voter for a specific election and email" do
      expect(Decidim::Vocdoni::Voter.search_user_email(election, "user@example.com")).to eq(voter)
    end
  end

  describe ".clear" do
    before { create_list(:vocdoni_voter, 3, election: election, token: "some_token") }

    it "removes all voters for a specific election" do
      expect { Decidim::Vocdoni::Voter.clear(election) }.to change(Decidim::Vocdoni::Voter, :count).by(-3)
    end
  end

  describe ".clear with empty voters list" do
    it "does not raise error when no voters to clear" do
      expect { Decidim::Vocdoni::Voter.clear(election) }.not_to raise_error
    end
  end

  describe "#update_in_vocdoni_census!" do
    context "when the wallet address changes" do
      it "updates the in_vocdoni_census flag" do
        subject.wallet_address = "new_address"
        subject.save!
        expect(subject.in_vocdoni_census).to be true
      end
    end
  end

  describe "#sent_to_vocdoni?" do
    it "returns the in_vocdoni_census value" do
      subject.in_vocdoni_census = true
      expect(subject.sent_to_vocdoni?).to be true
    end
  end
end
