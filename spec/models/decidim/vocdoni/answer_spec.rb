# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Answer do
  subject(:answer) { build(:vocdoni_election_answer) }

  it { is_expected.to be_valid }

  include_examples "resourceable"

  describe "#votes_percentage" do
    subject(:answer1) { create(:vocdoni_election_answer, question: question, votes: 5) }

    let(:question) { create(:vocdoni_question) }
    let!(:answer2) { create(:vocdoni_election_answer, question: question, votes: 10) }

    it "returns a percentage" do
      expect(subject.votes_percentage).to eq(33.33)
    end

    it "sums to 100" do
      expect(subject.votes_percentage + answer2.votes_percentage).to eq(100)
    end

    context "when there are multiple answers" do
      let!(:answer3) { create(:vocdoni_election_answer, question: question, votes: 11) }
      let!(:answer4) { create(:vocdoni_election_answer, question: question, votes: 22) }
      let!(:answer5) { create(:vocdoni_election_answer, question: question, votes: 33) }
      let!(:answer6) { create(:vocdoni_election_answer, question: question, votes: 1) }

      it "sums to 100" do
        expect(subject.question.answers.map(&:votes_percentage).sum).to eq(100)
      end
    end
  end

  describe "#slug" do
    subject(:answer) { build(:vocdoni_election_answer, id: 123) }

    it "returns the correct slug" do
      expect(subject.slug).to eq("answer-123")
    end
  end

  describe "#component" do
    subject(:answer) { create(:vocdoni_election_answer) }

    it "returns the component" do
      expect(subject.component).to eq(subject.election.component)
    end
  end
end
