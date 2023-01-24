# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::CreateQuestion do
  subject { described_class.new(form) }

  let(:organization) { current_component.organization }
  let(:participatory_process) { current_component.participatory_space }
  let(:current_component) { election.component }
  let(:election) { create :vocdoni_election }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      weight: 10,
      current_user: user,
      current_component: current_component,
      current_organization: organization,
      election: election
    )
  end
  let(:invalid) { false }

  let(:question) { Decidim::Vocdoni::Question.last }

  it "creates the question" do
    expect { subject.call }.to change(Decidim::Vocdoni::Question, :count).by(1)
  end

  it "stores the given data" do
    subject.call
    expect(translated(question.title)).to eq "title"
    expect(question.weight).to eq(10)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Vocdoni::Question,
        user,
        hash_including(:title, :weight),
        visibility: "all"
      )
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "create"
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the election has started" do
    let(:election) { create :election, :started }

    it "is not valid" do
      expect { subject.call }.to broadcast(:election_started)
    end
  end
end
