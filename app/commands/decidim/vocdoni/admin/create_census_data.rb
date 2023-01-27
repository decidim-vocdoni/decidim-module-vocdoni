# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A command with the business logic to create census data for an
      # election.
      class CreateCensusData < Decidim::Command
        def initialize(form, election)
          @form = form
          @election = election
        end

        # Executes the command. Broadcast this events:
        # - :ok when everything is valid
        # - :invalid when the form wasn't valid and couldn't proceed-
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @form.file

          data = @form.data
          return broadcast(:invalid) unless data

          # rubocop:disable Rails/SkipsModelValidations
          Voter.insert_all(@election, data.values)
          # rubocop:enable Rails/SkipsModelValidations

          broadcast(:ok)
        end
      end
    end
  end
end
