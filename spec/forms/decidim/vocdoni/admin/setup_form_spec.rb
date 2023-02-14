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
  let(:election) { create :vocdoni_election, :ready_for_setup, component: component }
  let(:component) { create :vocdoni_component, participatory_space: participatory_process }
  let(:participatory_process) { create :participatory_process, :published }
  let(:attributes) { {} }

  it { is_expected.to be_valid }

  it "shows messages" do
    expect(subject.messages).to match(
      hash_including({ minimum_photos: "The election has <strong>at least one photo</strong>." })
    )
    expect(subject.messages).to match(
      hash_including({ minimum_answers: "Each question has <strong>at least two answers</strong>." })
    )
    expect(subject.messages).to match(
      hash_including({ minimum_questions: "The election has <strong>at least one question</strong>." })
    )
    expect(subject.messages).to match(
      hash_including({ published: "The election is <strong>published</strong>." })
    )
    expect(subject.messages).to match(
      hash_including({ participatory_space_published: "The participatory space is <strong>published</strong>." })
    )
    expect(subject.messages).to match(
      hash_including({ census_ready: "The census is <strong>ready</strong>."})
    )
  end

  context "when the election is not ready for the setup" do
    let(:election) { create :vocdoni_election }

    it { is_expected.to be_invalid }

    it "shows errors" do
      subject.valid?
      expect(subject.errors.messages).to match(
        hash_including({ minimum_photos: ["The election <strong>must have at least one photo</strong>."] })
      )
      expect(subject.errors.messages).to match(
        hash_including({ minimum_questions: ["The election <strong>must have at least one question</strong>."] })
      )
      expect(subject.errors.messages).to match(
        hash_including({ minimum_answers: ["Questions must have <strong>at least two answers</strong>."] })
      )
      expect(subject.errors.messages).to match(
        hash_including({ published: ["The election is <strong>not published</strong>."] })
      )
      expect(subject.errors.messages).to match(
        hash_including({ census_ready: ["The census is <strong>not ready</strong>."] })
      )
    end
  end

  context "when the participatory space is not published" do
    let!(:participatory_process) { create :participatory_process, :unpublished }

    it { is_expected.to be_invalid }

    it "shows errors" do
      subject.valid?
      expect(subject.errors.messages).to match(
        hash_including({ participatory_space_published: ["The participatory space is <strong>not published</strong>."] })
      )
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
