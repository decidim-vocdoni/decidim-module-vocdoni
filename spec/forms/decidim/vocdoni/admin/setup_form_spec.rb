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
  let(:component) { create :vocdoni_component }
  let(:attributes) { {} }

  before do
    allow(Decidim::Vocdoni).to receive(:setup_minimum_minutes_before_start).and_return(10)
  end

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
      hash_including({ census_ready: "The census is <strong>ready</strong>." })
    )
    expect(subject.messages).to match(
      hash_including({ time_before: "The setup is being done <strong>at least 10 minutes</strong> before the election starts." })
    )
  end

  context "when the election is not ready for the setup" do
    let(:election) { create :vocdoni_election, start_time: 10.days.ago }

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
      expect(subject.errors.messages).to match(
        hash_including({ time_before: ["The setup is not being done <strong>at least 10 minutes</strong> before the election starts."] })
      )
    end
  end

  context "when the setup_minimum_minutes_before_start is different" do
    before do
      allow(Decidim::Vocdoni).to receive(:setup_minimum_minutes_before_start).and_return(33)
    end

    it "shows the message" do
      expect(subject.messages).to match(
        hash_including({
                         time_before: "The setup is being done <strong>at least 33 minutes</strong> before the election starts."
                       })
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
