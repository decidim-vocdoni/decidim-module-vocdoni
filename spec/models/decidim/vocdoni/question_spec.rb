# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Question do
  subject(:question) { build(:vocdoni_question) }

  it { is_expected.to be_valid }

  include_examples "resourceable"

  describe "#total_votes" do
    subject(:question) { create :vocdoni_question, :complete }

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
    subject(:question) { create :vocdoni_question, :complete }

    it "assigns a value to each answer" do
      expect { subject.build_answer_values! }.to change { subject.answers.pluck(:value) }.from([nil, nil, nil]).to([0, 1, 2])
    end
  end

  describe "#to_vocdoni" do
    let(:question1) { create :vocdoni_question, :complete }
    let(:question2) { create :vocdoni_question, :complete }
    let(:vocdoni1) { question1.to_vocdoni }
    let(:vocdoni2) { question2.to_vocdoni }

    it "returns the question in the Vocdoni format" do
      question1.build_answer_values!
      expect(vocdoni1[0]["en"]).to eq(question1.title["en"])
      expect(vocdoni1[0]["ca"]).to eq(question1.title["ca"])
      expect(vocdoni1[0]["default"]).to eq(question1.title["en"])
      expect(vocdoni1[1]["en"]).to eq(question1.description["en"])
      expect(vocdoni1[1]["ca"]).to eq(question1.description["ca"])
      expect(vocdoni1[1]["default"]).to eq(question1.description["en"])
      expect(vocdoni1[2][0]["title"]["en"]).to eq(question1.answers[0].title["en"])
      expect(vocdoni1[2][0]["value"]).to eq(0)
      expect(vocdoni1[2][1]["title"]["en"]).to eq(question1.answers[1].title["en"])
      expect(vocdoni1[2][1]["value"]).to eq(1)
      expect(vocdoni1[2][2]["title"]["en"]).to eq(question1.answers[2].title["en"])
      expect(vocdoni1[2][2]["value"]).to eq(2)

      question2.build_answer_values!
      expect(vocdoni2[0]["en"]).to eq(question2.title["en"])
      expect(vocdoni2[0]["ca"]).to eq(question2.title["ca"])
      expect(vocdoni2[0]["default"]).to eq(question2.title["en"])
      expect(vocdoni2[1]["en"]).to eq(question2.description["en"])
      expect(vocdoni2[1]["ca"]).to eq(question2.description["ca"])
      expect(vocdoni2[1]["default"]).to eq(question2.description["en"])
      expect(vocdoni2[2][0]["title"]["en"]).to eq(question2.answers[0].title["en"])
      expect(vocdoni2[2][0]["value"]).to eq(0)
      expect(vocdoni2[2][1]["title"]["en"]).to eq(question2.answers[1].title["en"])
      expect(vocdoni2[2][1]["value"]).to eq(1)
      expect(vocdoni2[2][2]["title"]["en"]).to eq(question2.answers[2].title["en"])
      expect(vocdoni2[2][2]["value"]).to eq(2)
    end
  end

  describe "#slug" do
    subject(:question) { create :vocdoni_question }

    it "returns the correct slug format" do
      expect(subject.slug).to eq("question-#{subject.id}")
    end
  end
end
