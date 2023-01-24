# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::CreateAnswer do
  subject(:command) { described_class.new(form) }

  let(:organization) { component.organization }
  let(:participatory_process) { component.participatory_space }
  let(:component) { election.component }
  let(:question) { create :vocdoni_question, election: election }
  let(:election) { create :vocdoni_election }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      weight: 10,
      current_user: user,
      current_component: component,
      current_organization: organization,
      election: election,
      question: question
    )
  end
  let(:invalid) { false }

  let(:answer) { Decidim::Vocdoni::Answer.last }

  it "creates the answer" do
    expect { subject.call }.to change(Decidim::Vocdoni::Answer, :count).by(1)
  end

  it "stores the given data" do
    subject.call
    expect(translated(answer.title)).to eq "title"
    expect(translated(answer.description)).to eq "description"
    expect(answer.weight).to eq(10)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Vocdoni::Answer,
        user,
        hash_including(:title, :description, :weight),
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
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
