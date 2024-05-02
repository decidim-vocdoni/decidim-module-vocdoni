# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    describe CensusAuthorizationModalCell, type: :cell do
      controller Decidim::Vocdoni::ElectionsController

      subject { cell("decidim/vocdoni/census_authorization_modal", model) }

      let(:model) { create(:vocdoni_election, :published, :started, :with_internal_census, verification_types:) }
      let(:verification_types) { [authorization_handler_name] }
      let(:current_user) { create(:user, :confirmed, organization:) }
      let(:organization) { create(:organization, available_authorizations: [authorization_handler_name]) }
      let(:voter) { create(:vocdoni_voter, election: model, email: current_user.email) }
      let(:authorization_handler_name) { "id_documents" }
      let(:authorization) { create(:authorization, name: authorization_handler_name, user: current_user, granted_at: 1.day.ago) }

      before do
        allow(controller).to receive(:current_user).and_return(current_user)
      end

      describe "#modal_id" do
        context "when current_user is present" do
          it "returns 'internalCensusModal'" do
            allow(controller).to receive(:current_user).and_return(current_user)
            expect(subject.modal_id).to eq "internalCensusModal"
          end
        end

        context "when current_user is nil" do
          it "returns 'loginModal'" do
            allow(controller).to receive(:current_user).and_return(nil)
            expect(subject.modal_id).to eq "loginModal"
          end
        end
      end

      describe "#render_internal_census" do
        let(:granted_authorizations) { [] }

        context "when the authorized method is not granted" do
          it "renders the internal census view" do
            expect(subject).to receive(:render).with(view: "internal_census", locals: hash_including(authorized_method: authorization_handler_name))
            subject.render_internal_census(authorization_handler_name, granted_authorizations)
          end
        end

        context "when the authorized method is already granted" do
          it "does not render the internal census view" do
            granted_authorizations << authorization_handler_name
            expect(subject).not_to receive(:render)
            subject.render_internal_census(authorization_handler_name, granted_authorizations)
          end
        end
      end

      describe "#not_authorized_explanation" do
        let(:authorized_method) { double("AuthorizedMethod", key: "id_documents") }

        it "returns the not authorized explanation" do
          authorization_name = I18n.t("id_documents.name", scope: "decidim.authorization_handlers")
          expected_translation = I18n.t("not_authorized.explanation", authorization: authorization_name, scope: "decidim.vocdoni.census_authorization_modal")
          expect(subject.not_authorized_explanation(authorized_method)).to eq(expected_translation)
        end
      end

      describe "#authorize_link_text" do
        let(:authorized_method) { double("AuthorizedMethod", key: "id_documents") }

        it "returns the authorize link text" do
          authorization_name = I18n.t("id_documents.name", scope: "decidim.authorization_handlers")
          expected_translation = I18n.t("not_authorized.authorize", authorization: authorization_name, scope: "decidim.vocdoni.census_authorization_modal")
          expect(subject.authorize_link_text(authorized_method)).to eq(expected_translation)
        end
      end

      describe "#authorization_name" do
        let(:authorized_method) { double("AuthorizedMethod", key: "id_documents") }

        it "returns the authorization name" do
          expected_translation = I18n.t("id_documents.name", scope: "decidim.authorization_handlers")
          expect(subject.authorization_name(authorized_method)).to eq(expected_translation)
        end
      end
    end
  end
end
