# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user updates an Answer
      # from the admin panel.
      class UpdateAnswer < Decidim::Command
        def initialize(form, answer)
          @form = form
          @answer = answer
          @attached_to = answer
        end

        # Updates the answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          transaction do
            update_answer
          end

          broadcast(:ok, answer)
        end

        private

        attr_reader :form, :answer

        def invalid?
          form.election.blocked? || form.invalid?
        end

        def update_answer
          attributes = {
            question: form.question,
            title: form.title,
            description: form.description,
            weight: form.weight
          }

          Decidim.traceability.update!(
            answer,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
