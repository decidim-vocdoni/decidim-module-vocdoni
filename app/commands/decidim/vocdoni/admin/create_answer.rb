# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user creates an Answer
      # from the admin panel.
      class CreateAnswer < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the answer if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if invalid?

          transaction do
            create_answer
          end

          broadcast(:ok, answer)
        end

        private

        attr_reader :form, :answer

        def invalid?
          form.election.blocked? || form.invalid?
        end

        def create_answer
          attributes = {
            question: form.question,
            title: form.title,
            description: form.description,
            weight: form.weight
          }

          @answer = Decidim.traceability.create!(
            Answer,
            form.current_user,
            attributes,
            visibility: "all"
          )
          @attached_to = @answer
        end
      end
    end
  end
end
