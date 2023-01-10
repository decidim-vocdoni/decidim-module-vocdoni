# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This cell renders the results
    # for a given instance of an Election
    class ElectionVoteCtaCell < Decidim::ViewModel
      include Decidim::Vocdoni::HasVoteFlow

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
        engine_router.election_vote_verify_path(
          "#{key_participatory_space_slug}": current_participatory_space.slug,
          component_id: current_component.id,
          election_id: model.id,
          vote_id: "_"
        )
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
