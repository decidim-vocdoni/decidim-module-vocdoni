# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This cell renders the results
    # for a given instance of an Election
    class ElectionVoteCtaCell < Decidim::ViewModel
      include Decidim::Vocdoni::HasVoteFlow
      include Decidim::Vocdoni::VoterVerifications
      include Decidim::Vocdoni::Engine.routes.url_helpers

      delegate :current_user,
               :current_participatory_space,
               :allowed_to?,
               :preview_mode?,
               to: :controller

      private

      # This is needed by HasVoteFlow
      def election
        model
      end

      def modal_id
        return "loginModal" unless current_user

        options[:modal_id] || "internalCensusModal"
      end

      def new_election_vote_path
        engine_router.new_election_vote_path(
          "#{key_participatory_space_slug}": current_participatory_space.slug,
          component_id: current_component.id,
          election_id: model.id
        )
      end

      def vote_action_button_text
        t("action_button.vote", scope: "decidim.vocdoni.elections.show")
      end

      def election_vote_verify_path
        "https://#{Decidim::Vocdoni.explorer_vote_domain}/verify"
      end

      def callout_text
        ""
      end

      def current_component
        model.component
      end

      def key_participatory_space_slug
        "#{current_participatory_space.underscored_name}_slug".to_sym
      end

      def engine_router
        @engine_router ||= EngineRouter.main_proxy(current_component || model)
      end
    end
  end
end
