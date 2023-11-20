# frozen_string_literal: true

module Decidim
  module Vocdoni
    # The cell renders the census authorization modal
    # when the user clicks on the "Vote" button and doesn't have
    # the required authorizations
    class CensusAuthorizationModalCell < Decidim::ViewModel
      include Decidim::IconHelper
      include Decidim::Vocdoni::VoterVerifications

      def show
        render
      end

      def election
        model
      end

      def modal_id
        return "loginModal" unless current_user

        options[:modal_id] || "internalCensusModal"
      end

      def render_internal_census(authorized_method, granted_authorizations)
        unless granted_authorizations.include?(authorized_method)
          render view: "internal_census", locals: {
            authorized_method: authorized_method,
            granted: granted_authorizations.include?(authorized_method)
          }
        end
      end

      def not_authorized_explanation(authorized_method)
        t("not_authorized.explanation", authorization: authorization_name(authorized_method), scope: "decidim.vocdoni.census_authorization_modal")
      end

      def authorize_link_text(authorized_method)
        t("not_authorized.authorize", authorization: authorization_name(authorized_method), scope: "decidim.vocdoni.census_authorization_modal")
      end

      def authorization_name(authorized_method)
        t("#{authorized_method.key}.name", scope: "decidim.authorization_handlers")
      end
    end
  end
end
