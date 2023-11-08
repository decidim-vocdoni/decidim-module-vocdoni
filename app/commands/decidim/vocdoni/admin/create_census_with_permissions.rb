# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A command with the business logic to create census data for an
      # election.
      class CreateCensusWithPermissions < Decidim::Command
        TOKEN = "verified"
        CENSUS_TYPE = "census_permissions"

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

          Voter.insert_participants_with_permissions(@election, users_data, TOKEN)
          update_census_type(CENSUS_TYPE)
          update_verification_types(@form.census_permissions)
          broadcast(:ok)
        end

        private

        def fetch_verified_users
          @form.data.map { |user| [user.email] }
        end

        def update_census_type(census_type)
          @election.update!(census_type: census_type)
        end

        def update_verification_types(types)
          @election.update!(verification_types: types) if types.present?
        end
      end
    end
  end
end
