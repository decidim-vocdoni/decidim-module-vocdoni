# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::UpdateQuestion do
  subject { described_class.new(form, question) }

  let(:election) { create :election }
  let(:question) { create :question, election: election }
  let(:organization) { election.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      title: { en: "title" },
      weight: 10,
      election: election
    )
  end
  let(:invalid) { false }

  it "updates the question" do
    subject.call
    expect(translated(question.title)).to eq "title"
    expect(question.weight).to eq(10)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:update!)
      .with(question, user, hash_including(:title, :weight), visibility: "all")
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "update"
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
