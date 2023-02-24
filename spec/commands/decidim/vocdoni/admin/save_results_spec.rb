# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::SaveResults do
  subject { described_class.new(form) }

  let(:election) { create :vocdoni_election }
  let(:question) { create :vocdoni_question, election: election }
  let(:answer1) { create :vocdoni_election_answer, question: question }
  let(:answer2) { create :vocdoni_election_answer, question: question }
  let(:organization) { election.component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    double(
      invalid?: invalid,
      election: election,
      current_user: user,
      results: results,
      status: "vote_period"
    )
  end
  let(:results) do
    [
      { id: answer1.id, votes: 100 },
      { id: answer2.id, votes: 99 }
    ]
  end
  let(:invalid) { false }

  it "saves the results" do
    subject.call
    expect(answer1.reload.votes).to eq 100
    expect(answer2.reload.votes).to eq 99
  end

  it "updates the election" do
    subject.call
    expect(election.reload.status).to eq "results_published"
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:save_results, election, user, extra: { results: results, status: "results_published" })
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "update"
  end

  context "when the results are empty" do
    let(:results) do
      []
    end

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the results don't correspond with the Answers" do
    let(:results) do
      [
        { id: 101, votes: 100 },
        { id: 102, votes: 99 }
      ]
    end

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
