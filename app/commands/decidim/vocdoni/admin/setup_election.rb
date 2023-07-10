# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when a election is setup from the admin panel.
      class SetupElection < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A SetupForm object with the information needed to setup the election
        def initialize(form)
          @form = form
        end

        # Public: Setup the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            log_action
            update_election
          end

          broadcast(:ok, election)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        delegate :election, to: :form

        def update_election
          election.vocdoni_election_id = form.vocdoni_election_id
          election.status = :created
          election.start_time = Time.zone.now + Decidim::Vocdoni.manual_start_time_delay if election.manual_start?
          election.blocked_at = Time.zone.now
          election.status = :paused if election.manual_start?
          election.save!
        end

        def log_action
          Decidim.traceability.perform_action!(
            :setup,
            election,
            form.current_user,
            visibility: "all"
          )
        end
      end
    end
  end
end
