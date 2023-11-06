# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A command with the business logic to create census data for an
      # election.
      class CensusPermissions < Decidim::Command
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

          Voter.insert_participants_with_permissions(@election, users_data, token: "verified")

          broadcast(:ok)
        end

        private

        def fetch_verified_users
          @form.data.map { |user| [user.email] }
        end
      end
    end
  end
end
