# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:organization) { elections_component.organization }
  let(:user) { create :user, organization: organization }
  let(:context) do
    {
      current_component: elections_component,
      election: election
    }
  end
  let(:elections_component) { create :vocdoni_component }
  let(:election) { create :election, :published, component: elections_component }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :election }
    end

    it_behaves_like "delegates permissions to", Decidim::Vocdoni::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not an election" do
    let(:action) do
      { scope: :public, action: :bar, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action) do
      { scope: :public, action: :bar, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  describe "election view" do
    let(:action) do
      { scope: :public, action: :view, subject: :election }
    end

    it { is_expected.to be_truthy }

    context "when election is not published" do
      let(:election) { create :election, :upcoming, component: elections_component }

      it { is_expected.to be_falsey }

      context "when user is not logged in" do
        let(:user) { nil }

        it { is_expected.to be_falsey }
      end

      context "when user is an administrator" do
        let(:user) { create :user, :admin, organization: elections_component.organization }

        it { is_expected.to be_truthy }
      end
    end

    context "when user is not logged in" do
      let(:user) { nil }

      it { is_expected.to be_truthy }
    end
  end

  describe "election preview" do
    let(:action) do
      { scope: :public, action: :preview, subject: :election }
    end

    it { is_expected.to be_falsey }

    context "when user is an administrator" do
      let(:user) { create :user, :admin, organization: elections_component.organization }

      it { is_expected.to be_truthy }
    end
  end
end
