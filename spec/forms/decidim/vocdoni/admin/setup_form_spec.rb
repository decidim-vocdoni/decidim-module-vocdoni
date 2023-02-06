# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::SetupForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election: election,
      current_step: "create_election"
    }
  end
  let(:election) { create :vocdoni_election, :ready_for_setup }
  let(:component) { election.component }
  let(:attributes) { {} }

  it { is_expected.to be_valid }

  it "shows messages" do
    expect(subject.messages).to match(
      hash_including({
                       minimum_answers: "Each question has <strong>at least 2 answers</strong>.",
                       minimum_questions: "The election has <strong>at least 1 question</strong>.",
                       published: "The election is <strong>published</strong>.",
                       census_ready: "The census is <strong>ready</strong>."
                     })
    )
  end

  context "when the election is not ready for the setup" do
    let(:election) { create :vocdoni_election }

    it { is_expected.to be_invalid }

    it "shows errors" do
      subject.valid?
      expect(subject.errors.messages).to eq({
                                              minimum_questions: ["The election <strong>must have at least one question</strong>."],
                                              minimum_answers: ["Questions must have <strong>at least two answers</strong>."],
                                              published: ["The election is <strong>not published</strong>."],
                                              census_ready: ["The census is <strong>not ready</strong>."]
                                            })
    end
  end

  context "when there are no answers created" do
    let(:election) { create :vocdoni_election, :published }
    let!(:question) { create :vocdoni_question, election: election, weight: 1 }

    it { is_expected.to be_invalid }

    it "shows errors" do
      subject.valid?
      expect(subject.errors.messages).to match(
        hash_including({
                         minimum_answers: ["Questions must have <strong>at least two answers</strong>."]
                       })
      )
    end
  end
end
