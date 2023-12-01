# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A command with the business logic to create census data for an
      # election.
      class CreateInternalCensus < Decidim::Command
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
          return broadcast(:invalid) unless @form.valid?

          users_data = fetch_verified_users

          # rubocop:disable Rails/SkipsModelValidations
          Voter.insert_all(@election, users_data) if users_data.present?
          # rubocop:enable Rails/SkipsModelValidations

          update_census_type
          update_verification_types(@form.verification_types)
          update_election_type
          broadcast(:ok)
        end

        private

        def fetch_verified_users
          @form.data.map do |user|
            [user.email, token_for_voter(user.email)]
          end
        end

        def token_for_voter(email)
          "#{email}-#{@election.id}-#{SecureRandom.hex(16)}"
        end

        def update_census_type
          @election.update!(internal_census: true)
        end

        def update_verification_types(types)
          @election.update!(verification_types: types) || []
        end

        def update_election_type
          return unless @election.internal_census?

          @election.update!(election_type: { dynamic_census: true })
        end
      end
    end
  end
end