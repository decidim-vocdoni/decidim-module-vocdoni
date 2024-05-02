# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::SaveResults do
  subject { described_class.new(form) }

  let(:election) { create(:vocdoni_election) }
  let(:question1) { create(:vocdoni_question, election:, weight: 1) }
  let!(:answer11) { create(:vocdoni_election_answer, question: question1, value: 1) }
  let!(:answer12) { create(:vocdoni_election_answer, question: question1, value: 0) }
  let(:question2) { create(:vocdoni_question, election:, weight: 0) }
  let!(:answer21) { create(:vocdoni_election_answer, question: question2, value: 0) }
  let!(:answer22) { create(:vocdoni_election_answer, question: question2, value: 1) }

  let(:organization) { election.component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    double(
      election:,
      current_user: user
    )
  end
  let(:results) do
    [
      [2, 71],
      [3, 14]
    ]
  end

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Decidim::Vocdoni::Sdk).to receive(:electionMetadata).and_return({ "results" => results })
    # rubocop:enable RSpec/AnyInstance
  end

  it "saves the results" do
    expect(answer11.votes).to be_nil
    expect(answer12.votes).to be_nil
    expect(answer21.votes).to be_nil
    expect(answer22.votes).to be_nil
    perform_enqueued_jobs { subject.call }
    expect(answer11.reload.votes).to eq 14
    expect(answer12.reload.votes).to eq 3
    expect(answer21.reload.votes).to eq 2
    expect(answer22.reload.votes).to eq 71
  end

  context "when results does not match" do
    let(:results) do
      [
        [2, 71]
      ]
    end

    it "completes what's available" do
      perform_enqueued_jobs { subject.call }
      expect(answer11.reload.votes).to be_nil
      expect(answer12.reload.votes).to be_nil
      expect(answer21.reload.votes).to eq 2
      expect(answer22.reload.votes).to eq 71
    end
  end

  it "updates the election" do
    perform_enqueued_jobs { subject.call }
    expect(election.reload.status).to eq "results_published"
  end

  it "traces the action", :versioning do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:save_results, election, user, extra: { status: "results_published" })
      .and_call_original

    expect { perform_enqueued_jobs { subject.call } }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "update"
  end
end
