# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user creates an Election
      # from the admin panel.
      class CreateElection < Decidim::Command
        include ::Decidim::AttachmentMethods
        include ::Decidim::GalleryMethods

        def initialize(form)
          @form = form
        end

        # Creates the election if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            create_election!
            create_gallery if process_gallery?
          end

          broadcast(:ok, election)
        end

        private

        attr_reader :form, :election, :gallery

        def create_election!
          attributes = {
            title: form.title,
            description: form.description,
            stream_uri: form.stream_uri,
            component: form.current_component
          }

          @election = Decidim.traceability.create!(
            Election,
            form.current_user,
            attributes,
            visibility: "all"
          )
          @attached_to = @election
        end
      end
    end
  end
end
