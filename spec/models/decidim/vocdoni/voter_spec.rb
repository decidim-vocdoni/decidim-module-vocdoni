# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Voter do
  subject(:voter) { build :vocdoni_voter }

  let(:election) { create :vocdoni_election }

  describe ".insert_all" do
    let(:values) do
      [
        ["user1@example.org", "2000-01-01"],
        ["user2@example.org", "2001-01-01"]
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
      expect(voter1.born_at).to eq Date.parse("2000-01-01")
      expect(voter1.election).to eq election

      voter2 = Decidim::Vocdoni::Voter.second
      expect(voter2.email).to eq "user2@example.org"
      expect(voter2.born_at).to eq Date.parse("2001-01-01")
      expect(voter2.election).to eq election
    end

    context "when the email isn't lowercase" do
      let(:values) do
        [
          ["USER1@example.org", "2000-01-01"]
        ]
      end

      it "is normalized" do
        expect(Decidim::Vocdoni::Voter.first.email).to eq("user1@example.org")
      end
    end
  end
end
