# frozen_string_literal: true

require "spec_helper"

module Decidim::Vocdoni::Admin
  describe CensusPermissionsForm do
    subject { described_class.from_params(verification_types: verification_types).with_context(context) }

    let(:verification_types) { %w(id_documents postal_letter) }
    let(:users) { create_list(:user, 5, :confirmed, organization: current_organization) }
    let(:other_users) { create_list(:user, 3, :confirmed, organization: current_organization) }
    let(:users_other_org) { create_list(:user, 2, :confirmed) }
    let(:current_organization) { create(:organization) }
    let(:context) { double("Context", current_organization: current_organization) }

    before do
      users.each do |user|
        create(:authorization, name: verification_types[0], user: user)
        create(:authorization, name: verification_types[1], user: user)
      end

      users_other_org.each do |user|
        create(:authorization, name: verification_types[0], user: user)
        create(:authorization, name: verification_types[1], user: user)
      end

      allow(current_organization).to receive(:available_authorizations).and_return([verification_types[0], verification_types[1]])
    end

    describe "#data" do
      it "returns users with the given verification types" do
        expect(subject.data).to match_array(users)
      end
    end
  end
end
