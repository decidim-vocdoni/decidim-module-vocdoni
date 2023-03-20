# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::UpdateAnswersValues do
  subject(:command) { described_class.new(election) }

  let(:election) { create :vocdoni_election }
  let(:question) { create :vocdoni_question, election: election }
  let!(:answer1) { create :vocdoni_election_answer, question: question, value: nil }
  let!(:answer2) { create :vocdoni_election_answer, question: question, value: nil }

  it "updates the answers values" do
    expect(answer1.value).to be_nil
    expect(answer2.value).to be_nil
    subject.call
    expect(answer1.reload.value).not_to be_nil
    expect(answer2.reload.value).not_to be_nil
  end
end
