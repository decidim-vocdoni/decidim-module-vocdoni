# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Question do
  subject(:question) { build(:vocdoni_question) }

  it { is_expected.to be_valid }

  include_examples "resourceable"

  describe "#total_votes" do
    subject(:question) { create(:vocdoni_question, :complete) }

    before do
      # rubocop:disable Rails/SkipsModelValidations
      question.answers.update_all(votes: 5)
      # rubocop:enable Rails/SkipsModelValidations
    end

    it "returns the total number of votes" do
      expect(subject.total_votes).to eq 15
    end
  end

  describe "#build_answer_values!" do
    subject(:question) { create(:vocdoni_question, :complete) }

    it "assigns a value to each answer" do
      expect { subject.build_answer_values! }.to change { subject.answers.pluck(:value) }.from([nil, nil, nil]).to([0, 1, 2])
    end
  end

  describe "#to_vocdoni" do
    let(:first_question) { create(:vocdoni_question, :complete) }
    let(:second_question) { create(:vocdoni_question, :complete) }
    let(:first_vocdoni) { first_question.to_vocdoni }
    let(:second_vocdoni) { second_question.to_vocdoni }

    it "returns the question in the Vocdoni format" do
      first_question.build_answer_values!
      expect(first_vocdoni[0]["en"]).to eq(first_question.title["en"])
      expect(first_vocdoni[0]["ca"]).to eq(first_question.title["ca"])
      expect(first_vocdoni[0]["default"]).to eq(first_question.title["en"])
      expect(first_vocdoni[1]["en"]).to eq(first_question.description["en"])
      expect(first_vocdoni[1]["ca"]).to eq(first_question.description["ca"])
      expect(first_vocdoni[1]["default"]).to eq(first_question.description["en"])
      expect(first_vocdoni[2][0]["title"]["en"]).to eq(first_question.answers[0].title["en"])
      expect(first_vocdoni[2][0]["value"]).to eq(0)
      expect(first_vocdoni[2][1]["title"]["en"]).to eq(first_question.answers[1].title["en"])
      expect(first_vocdoni[2][1]["value"]).to eq(1)
      expect(first_vocdoni[2][2]["title"]["en"]).to eq(first_question.answers[2].title["en"])
      expect(first_vocdoni[2][2]["value"]).to eq(2)

      second_question.build_answer_values!
      expect(second_vocdoni[0]["en"]).to eq(second_question.title["en"])
      expect(second_vocdoni[0]["ca"]).to eq(second_question.title["ca"])
      expect(second_vocdoni[0]["default"]).to eq(second_question.title["en"])
      expect(second_vocdoni[1]["en"]).to eq(second_question.description["en"])
      expect(second_vocdoni[1]["ca"]).to eq(second_question.description["ca"])
      expect(second_vocdoni[1]["default"]).to eq(second_question.description["en"])
      expect(second_vocdoni[2][0]["title"]["en"]).to eq(second_question.answers[0].title["en"])
      expect(second_vocdoni[2][0]["value"]).to eq(0)
      expect(second_vocdoni[2][1]["title"]["en"]).to eq(second_question.answers[1].title["en"])
      expect(second_vocdoni[2][1]["value"]).to eq(1)
      expect(second_vocdoni[2][2]["title"]["en"]).to eq(second_question.answers[2].title["en"])
      expect(second_vocdoni[2][2]["value"]).to eq(2)
    end
  end

  describe "#slug" do
    subject(:question) { create(:vocdoni_question) }

    it "returns the correct slug format" do
      expect(subject.slug).to eq("question-#{subject.id}")
    end
  end
end
