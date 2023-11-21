# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    describe SendDataToVocdoniJob do
      subject { described_class }

      let!(:organization) { create(:organization, available_authorizations: available_authorizations) }
      let!(:available_authorizations) { [dummy_authorization_handler_name, id_document_handler_name] }
      let!(:id_document_handler_name) { "id_document_handler" }
      let!(:dummy_authorization_handler_name) { "dummy_authorization_handler" }
      let!(:user_with_authorizations) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:second_user_with_authorizations) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:id_document_authorization) { create(:authorization, user: user_with_authorizations, name: id_document_handler_name) }
      let!(:id_document_authorization_second) { create(:authorization, user: second_user_with_authorizations, name: id_document_handler_name) }
      let!(:election) { create(:vocdoni_election, :upcoming, :with_internal_census, verification_types: [id_document_handler_name]) }
      let!(:authorizations_data_first) { create(:vocdoni_authorizations_data, election: election, authorization: id_document_authorization) }
      let!(:authorizations_data_second) { create(:vocdoni_authorizations_data, election: election, authorization: id_document_authorization_second) }

      it "groups authorization data by election and processes them" do
        expect { subject.perform_now }.to change(Decidim::Vocdoni::Voter, :count).by(2)
      end
    end
  end
end
