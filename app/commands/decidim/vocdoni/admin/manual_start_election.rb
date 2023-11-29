# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when a election is started by the admin
      class ManualStartElection < Decidim::Command
        # Public: Initializes the command.
        #
        # election - The election to start.
        def initialize(election)
          @election = election
        end

        # Public: Starts the Election.
        #
        # Broadcasts :ok if started
        def call
          sdk.continueElection if sdk.electionMetadata["status"] == "PAUSED"
          start_election
          broadcast(:ok, election)
        rescue StandardError => e
          Rails.logger.error e.message
          broadcast(:error, sdk.last_error)
        end

        private

        attr_reader :election

        def sdk
          @sdk ||= Decidim::Vocdoni::Sdk.new(election.organization, election)
        end

        def start_election
          election.update(status: :vote)
        end
      end
    end
  end
end
