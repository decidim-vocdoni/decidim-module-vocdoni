# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::UpdateAnswer do
  subject(:command) { described_class.new(form, answer) }

  let(:election) { create(:vocdoni_election) }
  let(:question) { create(:vocdoni_question, election:) }
  let(:answer) { create(:vocdoni_election_answer, question:) }
  let(:component) { election.component }
  let(:organization) { component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      title: { en: "title" },
      description: { en: "description" },
      weight: 10,
      election:,
      question:
    )
  end
  let(:invalid) { false }

  it "updates the answer" do
    subject.call
    expect(translated(answer.title)).to eq "title"
    expect(translated(answer.description)).to eq "description"
    expect(answer.weight).to eq(10)
  end

  it "traces the action", :versioning do
    expect(Decidim.traceability)
      .to receive(:update!)
      .with(answer, user, hash_including(:title, :description, :weight), visibility: "all")
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

  context "when the election is ongoing" do
    let(:election) { create(:vocdoni_election, :ongoing) }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
