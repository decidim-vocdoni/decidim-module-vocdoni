# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when saving the election time settings from the admin panel
      class UpdateElectionCalendar < Decidim::Command
        # Public: Initializes the command.
        #
        # form - An ElectionCalendarForm object with the time settings to update
        # election - The election to update
        def initialize(form, election)
          @form = form
          @election = election
        end

        # Public: Update Election Calendar
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_election!
          end

          broadcast(:ok, election)
        end

        private

        attr_reader :form, :election

        def update_election!
          attributes = {
            start_time: start_time,
            end_time: form.end_time
          }.merge(election_type_attributes)

          Decidim.traceability.update!(
            election,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end

        def election_type_attributes
          {
            election_type: {
              auto_start: !form.manual_start,
              secret_until_the_end: form.result_type == "after_voting",
              interruptible: true,
              dynamic_census: form.dynamic_census,
              anonymous: form.anonymous
            }
          }
        end

        def start_time
          form.manual_start ? nil : form.start_time
        end
      end
    end
  end
end
