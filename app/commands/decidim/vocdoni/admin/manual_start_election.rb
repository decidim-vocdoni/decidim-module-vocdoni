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
          start_election

          broadcast(:ok, election)
        end

        private

        attr_reader :election

        def start_election
          election.update(status: :vote)
        end
      end
    end
  end
end
