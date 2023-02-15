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
end
