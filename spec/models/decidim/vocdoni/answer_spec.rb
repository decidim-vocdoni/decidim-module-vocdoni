# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Answer do
  subject(:answer) { build(:vocdoni_election_answer) }

  it { is_expected.to be_valid }

  include_examples "resourceable"

  describe "#votes_percentage" do
    subject(:answer) { create(:vocdoni_election_answer, question: question, votes: 5) }

    let(:question) { create(:vocdoni_question) }
    let!(:other_answer) { create(:vocdoni_election_answer, question: question, votes: 10) }

    it "returns a percentage" do
      expect(subject.votes_percentage).to eq(33)
    end
  end
end
