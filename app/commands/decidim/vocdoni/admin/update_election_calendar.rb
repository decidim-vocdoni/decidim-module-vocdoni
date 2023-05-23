# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when saving the election time settings from the admin panel
      class UpdateElectionCalendar < Decidim::Command
        # Public: Initializes the command.
        # form - An ElectionCalendarForm object with the time settings to update
        # election - The election to update
        def initialize(form, election)
          @form = form
          @election = election
        end

        # Public: Update Election Calendar
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            change_election_calendar
          end

          broadcast(:ok, election)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :election

        def change_election_calendar
          election.start_time = form.start_time
          election.end_time = form.end_time
          election.election_type = election_type_attributes
          election.save!
        end

        def election_type_attributes
          {
            election_type: {
              auto_start: form.auto_start,
              secret_until_the_end: form.secret_until_the_end
            }
          }
        end
      end
    end
  end
end
