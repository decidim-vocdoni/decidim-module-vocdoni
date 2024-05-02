# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Exposes the elections resources so users can participate on them
    class VotesController < Decidim::Vocdoni::ApplicationController
      layout "decidim/vocdoni_votes"
      include Decidim::Vocdoni::HasVoteFlow
      include Decidim::Vocdoni::VoterVerifications
      include FormFactory

      helper VotesHelper
      helper_method :exit_path, :elections, :election, :questions, :questions_count,
                    :preview_mode?, :election_unique_id, :vocdoni_api_endpoint_env, :voter_not_yet_in_census?

      delegate :count, to: :questions, prefix: true

      def show
        enforce_permission_to :view, :election, election:
      end

      def new
        return unless vote_allowed?

        @form = form(LoginForm).instance
      end

      def votes_left
        votes_left = params[:votesLeft]
        message = helpers.votes_left_message(votes_left.to_i)
        render json: { message: }
      end

      def check_verification
        render json: { isVerified: voter_verified?, email: voter&.email, election_id: election.id, token: voter&.token }
      end

      private

      def election_unique_id
        election.vocdoni_election_id
      end

      def exit_path
        @exit_path ||= if allowed_to?(:view, :election, election:)
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

          redirect_to(exit_path, alert: t("votes.messages.not_allowed", scope: "decidim.vocdoni"))
          return false
        end

        unless can_vote?
          redirect_to(exit_path, alert: t("votes.messages.not_allowed", scope: "decidim.vocdoni"))
          return false
        end

        enforce_permission_to(:vote, :election, election:)

        true
      end

      def voter_not_yet_in_census?
        voter.nil?
      end
    end
  end
end
