# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Vocdoni::ApplicationController
      layout "decidim/vocdoni_votes"
      include Decidim::Vocdoni::HasVoteFlow
      include FormFactory

      helper VotesHelper
      helper_method :exit_path, :elections, :election, :questions, :questions_count, :vote,
                    :preview_mode?, :election_unique_id, :vocdoni_api_endpoint_env

      delegate :count, to: :questions, prefix: true

      def new
        return unless vote_allowed?

        @form = form(LoginForm).instance
      end

      def show
        enforce_permission_to :view, :election, election: election
      end

      private

      def election_unique_id
        election.vocdoni_election_id
      end

      def exit_path
        @exit_path ||= if allowed_to? :view, :election, election: election
                         election_path(election)
                       else
                         elections_path
                       end
      end

      def elections
        @elections ||= Decidim::Vocdoni::Election.where(component: current_component)
      end

      def election
        @election ||= elections.find(params[:election_id])
      end

      def questions
        @questions ||= election.questions.includes(:answers).order(weight: :asc, id: :asc)
      end

      def vote_allowed?
        if preview_mode?
          return true if can_preview?

          redirect_to(
            exit_path,
            alert: t("votes.messages.not_allowed",
                     scope: "decidim.vocdoni")
          )
          return false
        end

        true
      end
    end
  end
end
