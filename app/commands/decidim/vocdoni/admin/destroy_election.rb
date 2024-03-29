# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user destroys an Election
      # from the admin panel.
      class DestroyElection < Decidim::Command
        include ::Decidim::AttachmentMethods
        include ::Decidim::GalleryMethods

        def initialize(election, current_user)
          @election = election
          @current_user = current_user
          @attached_to = election
        end

        # Destroys the election if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          destroy_election!

          broadcast(:ok, election)
        end

        private

        attr_reader :election, :current_user

        def invalid?
          election.blocked?
        end

        def destroy_election!
          Decidim.traceability.perform_action!(
            :delete,
            election,
            current_user,
            visibility: "all"
          ) do
            election.destroy!
          end
        end
      end
    end
  end
end
