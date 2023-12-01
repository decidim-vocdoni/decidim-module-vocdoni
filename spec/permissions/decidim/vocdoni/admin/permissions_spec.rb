# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: elections_component.organization }
  let(:context) do
    {
      current_component: elections_component,
      election: election
    }
  end
  let(:elections_component) { create :vocdoni_component }
  let(:election) { create :vocdoni_election, component: elections_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not an election" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :admin, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  describe "election creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :election }
    end
    let(:election) { nil }

    it { is_expected.to be true }
  end

  describe "election calendar" do
    let(:action) do
      { scope: :admin, action: :edit, subject: :election_calendar }
    end

    context "when everything is ok" do
      let(:election) { create :vocdoni_election, :with_census, component: elections_component }
      let(:question) { create :vocdoni_question, election: election }
      let!(:answers) { create_list(:vocdoni_election_answer, 2, question: question) }

      it { is_expected.to be true }
    end

    context "when election has no census" do
      let(:election) { create :vocdoni_election, component: elections_component }

      it { is_expected.to be false }
    end
  end

  describe "election update" do
    let(:action) do
      { scope: :admin, action: :update, subject: :election }
    end

    it { is_expected.to be true }
  end

  describe "election publish" do
    let(:action) do
      { scope: :admin, action: :publish, subject: :election }
    end

    context "when everything is ok" do
      let(:election) { create :vocdoni_election, :with_census, status: :created, component: elections_component }
      let(:question) { create :vocdoni_question, election: election }
      let!(:answers) { create_list(:vocdoni_election_answer, 2, question: question) }

      it { is_expected.to be true }
    end

    context "when election has no census" do
      let!(:election) { create :vocdoni_election, component: elections_component }

      it { is_expected.to be false }
    end

    context "when election has no calendar" do
      let(:election) { create :vocdoni_election, :with_census, end_time: nil, component: elections_component }

      it { is_expected.to be false }
    end
  end

  describe "election delete" do
    let(:action) do
      { scope: :admin, action: :delete, subject: :election }
    end

    it { is_expected.to be true }
  end

  describe "election unpublish" do
    let(:election) { create :vocdoni_election, :with_census, :published, status: :created, component: elections_component }
    let(:question) { create :vocdoni_question, election: election }
    let!(:answers) { create_list(:vocdoni_election_answer, 2, question: question) }
    let(:action) do
      { scope: :admin, action: :unpublish, subject: :election }
    end

    it { is_expected.to be true }
  end

  describe "wallet creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :wallet }
    end

    it { is_expected.to be true }

    context "when there's already a wallet for this organization" do
      let(:wallet) { create :vocdoni_wallet, organization: elections_component.organization }

      it { is_expected.to be true }
    end
  end
end
