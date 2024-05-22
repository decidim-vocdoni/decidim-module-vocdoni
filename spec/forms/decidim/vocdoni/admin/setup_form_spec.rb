# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::SetupForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election:,
      current_step: "create_election"
    }
  end
  let(:election) { create(:vocdoni_election, :ready_for_setup, :auto_start, start_time: 1.day.from_now, component:) }
  let(:component) { create(:vocdoni_component) }
  let(:attributes) { {} }
  let(:router) { Decidim::EngineRouter.admin_proxy(election.component) }

  before do
    allow(Decidim::Vocdoni).to receive(:minimum_minutes_before_start).and_return(10)
  end

  it { is_expected.to be_valid }

  it "shows messages" do
    expect(subject.messages).to match(
      hash_including(minimum_answers: hash_including(message: "Each question has <strong>at least two answers</strong>."))
    )
    expect(subject.messages).to match(
      hash_including(minimum_questions: hash_including(message: "The election has <strong>at least one question</strong>."))
    )
    expect(subject.messages).to match(
      hash_including(published: hash_including(message: "The election is <strong>published</strong>."))
    )
    expect(subject.messages).to match(
      hash_including(census_ready: hash_including(message: "The census is <strong>ready</strong>."))
    )
    expect(subject.messages).to match(
      hash_including(time_before: hash_including(message: "The setup is being done <strong>at least 10 minutes</strong> before the election starts."))
    )
  end

  context "when the election is not ready for the setup" do
    let(:election) { create(:vocdoni_election, :auto_start, start_time: 10.days.ago) }

    it { is_expected.not_to be_valid }

    it "shows errors" do
      subject.valid?
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

  context "when the minimum_minutes_before_start is different" do
    before do
      allow(Decidim::Vocdoni).to receive(:minimum_minutes_before_start).and_return(33)
    end

    it "shows the message" do
      expect(subject.messages[:time_before][:message]).to eq("The setup is being done <strong>at least 33 minutes</strong> before the election starts.")
    end
  end

  context "when there are no answers created" do
    let(:election) { create(:vocdoni_election, :published) }
    let!(:question) { create(:vocdoni_question, election:, weight: 1) }

    it { is_expected.not_to be_valid }

    it "shows errors" do
      subject.valid?
      expect(subject.errors.messages).to match(
        hash_including({
                         minimum_answers: ["Questions must have <strong>at least two answers</strong>."]
                       })
      )
    end
  end

  context "when manual start" do
    let(:election) { create(:vocdoni_election, :ready_for_setup, :manual_start, component:) }

    it { is_expected.to be_valid }

    it "does not show time_before message" do
      expect(subject.messages).not_to have_key(:time_before)
    end

    it "shows the message" do
      expect(subject.messages[:manual_start][:message]).to eq("The election <strong>will start manually.</strong>")
    end
  end
end
