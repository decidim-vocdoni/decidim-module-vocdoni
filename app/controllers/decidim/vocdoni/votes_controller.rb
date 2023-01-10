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
                    :preview_mode?, :voter_id, :election_unique_id

      delegate :count, to: :questions, prefix: true

      def new
        return unless vote_allowed?
      end

      def show
        enforce_permission_to :view, :election, election: election
      end

      def verify
        enforce_permission_to :view, :election, election: election
      end

      private

      # Needed for voting preview
      def voter_id
        SecureRandom.uuid.delete("-")
      end

      # Needed for voting preview
      def election_unique_id
        SecureRandom.uuid.delete("-")
      end

      def exit_path
        @exit_path ||= if allowed_to? :view, :election, election: election
                         election_path(election)
                       else
                         elections_path
                       end
      end

      def elections
        @elections ||= Election.where(component: current_component)
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
