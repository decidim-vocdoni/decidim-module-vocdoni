# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::SetupElection do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:invalid) { false }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "elections" }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:election) { create :election, :complete }
  let(:vocdoni_election_id) { "12345" }
  let(:form) do
    double(
      invalid?: invalid,
      election: election,
      vocdoni_election_id: vocdoni_election_id,
      current_user: user,
      current_component: current_component,
      current_organization: organization
    )
  end
  let(:method_name) { :create_election }

  context "when valid form" do
    it "updates the election status" do
      expect { subject.call }.to change { Decidim::Vocdoni::Election.last.status }.from(nil).to("created")
    end

    it "logs the performed action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:setup, election, user, visibility: "all")
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end

    it "blocks the election for modifications" do
      expect { subject.call }.to change(election, :blocked?).from(false).to(true)
      expect(election.blocked_at).to be_within(1.second).of election.updated_at
    end

    it "updates the vocdoni_election_id attribute" do
      expect { subject.call }.to change(election, :vocdoni_election_id).from(nil).to("12345")
    end
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
