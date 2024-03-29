# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user updates a Question
      # from the admin panel.
      class UpdateQuestion < Decidim::Command
        def initialize(form, question)
          @form = form
          @question = question
        end

        # Updates the question if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          update_question!

          broadcast(:ok, question)
        end

        private

        attr_reader :form, :question

        def invalid?
          question.election.blocked? || form.invalid?
        end

        def update_question!
          attributes = {
            title: form.title,
            description: form.description,
            weight: form.weight
          }

          Decidim.traceability.update!(
            question,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
