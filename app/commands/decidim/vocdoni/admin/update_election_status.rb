# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when saving the election status from the admin panel
      # To be used only when the election is interruptible
      class UpdateElectionStatus < Decidim::Command
        # Public: Initializes the command.
        #
        # form - An ElectionStatusForm object with the status to update
        def initialize(form)
          @form = form
        end

        # Public: Update Election Status
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            change_election_status
            log_action
          end

          broadcast(:ok, election)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        delegate :election, to: :form

        def change_election_status
          election.status = form.status
          election.save!
        end

        def log_action
          Decidim.traceability.perform_action!(
            :change_election_status,
            election,
            form.current_user
          )
        end
      end
    end
  end
end
