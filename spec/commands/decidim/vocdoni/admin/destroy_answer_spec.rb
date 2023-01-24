# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::DestroyAnswer do
  subject(:command) { described_class.new(answer, user) }

  let(:election) { create :vocdoni_election }
  let(:question) { create :vocdoni_question, election: election }
  let!(:answer) { create :vocdoni_election_answer, question: question }
  let(:component) { election.component }
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  it "destroys the answer" do
    expect { subject.call }.to change(Decidim::Vocdoni::Answer, :count).by(-1)
  end

  it "traces the action", versioning: true do
    expect(Decidim.traceability)
      .to receive(:perform_action!)
      .with(:delete, answer, user, visibility: "all")
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "destroy"
  end

  context "when the election has started" do
    let(:election) { create :vocdoni_election, :started }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
