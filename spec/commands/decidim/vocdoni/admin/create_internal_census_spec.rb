# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    module Admin
      describe CreateInternalCensus do
        subject { described_class.new(form, election) }

        let(:organization) { create(:organization, available_authorizations:) }
        let!(:available_authorizations) { verification_types + another_verification_types }
        let!(:election) { create(:vocdoni_election) }
        let(:form) { CensusPermissionsForm.from_params(params).with_context(current_organization: organization) }
        let(:verification_types) { ["id_document_handler"] }
        let(:invalid_verification_types) { ["invalid_handler"] }
        let(:another_verification_types) { ["another_handler"] }
        let(:verified_user) { create(:user, :confirmed, organization:) }
        let(:verified_user_second) { create(:user, :confirmed, organization:) }
        let!(:authorization) { create(:authorization, user: verified_user, name: "id_document_handler") }
        let!(:authorization_second) { create(:authorization, user: verified_user_second, name: "id_document_handler") }

        describe "when the form is valid" do
          let(:params) { { verification_types: } }

          it "creates voters and updates the election" do
            expect { subject.call }.to change(Decidim::Vocdoni::Voter, :count).by(2)
            expect(election.reload.internal_census).to be true
            expect(election.reload.verification_types).to eq(verification_types)
            expect(election.reload.election_type["dynamic_census"]).to be true
          end
        end

        describe "when the form is empty" do
          let(:params) { { verification_types: invalid_verification_types } }

          it "creates voters and updates the election" do
            expect { subject.call }.to change(Decidim::Vocdoni::Voter, :count).by(2)
            expect(election.reload.internal_census).to be true
            expect(election.reload.verification_types).not_to eq(invalid_verification_types)
            expect(election.reload.election_type["dynamic_census"]).to be true
          end
        end

        describe "when there are no verified users" do
          let(:params) { { verification_types: another_verification_types } }
          let(:technical_voter) { Decidim::Vocdoni::Voter.last }

          it "creates a technical voter and updates the election" do
            expect { subject.call }.to change(Decidim::Vocdoni::Voter, :count).by(1)
            expect(technical_voter.email).to eq(election.technical_voter_email)
            expect(election.reload.internal_census).to be true
            expect(election.reload.verification_types).to eq(another_verification_types)
            expect(election.reload.election_type["dynamic_census"]).to be true
            expect(election.reload.voters.last).to eq(technical_voter)
          end
        end
      end
    end
  end
end
