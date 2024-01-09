# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class VocdoniSdkBaseJob < ApplicationJob
        def perform(election_id)
          @election_id = election_id
        end

        private

        # Don't memoize this, we need a new instance always to ensure the election is updated
        def sdk
          Sdk.new(organization, election)
        end

        def organization
          @organization ||= election&.organization
        end

        def election
          @election ||= Decidim::Vocdoni::Election.find_by(id: @election_id)
        end
      end
    end
  end
end
