# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Vocdoni
    # Common logic for the vote flow
    module HasVoteFlow
      extend ActiveSupport::Concern

      def vocdoni_api_endpoint_env
        Decidim::Vocdoni.config.api_endpoint_env
      end

      def preview_mode?
        @preview_mode ||= !election.published? || !election.started?
      end

      def can_preview?
        @can_preview ||= allowed_to?(:preview, :election, election: election)
      end

      def ballot_questions
        election.questions
      end
    end
  end
end
