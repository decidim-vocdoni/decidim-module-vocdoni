# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user creates a Question
      # from the admin panel.
      class CreateQuestion < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the question if valid.
        #
        # Broadcasts:
        # * :ok if successful
        # * :election_ongoing if the election is already blocked
        # * :invalid otherwise.
        def call
          return broadcast(:election_ongoing) if form.election.blocked?
          return broadcast(:invalid) if form.invalid?

          create_question!

          broadcast(:ok, question)
        end

        private

        attr_reader :form, :question

        def create_question!
          attributes = {
            election: form.election,
            title: form.title,
            description: form.description,
            weight: form.weight
          }

          @question = Decidim.traceability.create!(
            Question,
            form.current_user,
            attributes,
            visibility: "all"
          )
        end
      end
    end
  end
end
