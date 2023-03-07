# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when a election has all the answers, and
      # before sending it to the Vocdoni API, so every Answer has a value
      # associated to it
      class UpdateAnswersValues < Decidim::Command
        # Public: Initializes the command.
        #
        # election - The election to set the values of the answers.
        def initialize(election)
          @election = election
        end

        # Public: Update the values of the Questions' Answers in an Election.
        #
        # Broadcasts :ok if published, :invalid otherwise.
        def call
          set_values_on_answers

          broadcast(:ok, election)
        end

        private

        attr_reader :election

        def set_values_on_answers
          election.questions.each do |question|
            question.answers.each_with_index do |answer, idx|
              answer.update!(value: idx)
            end
          end
        end
      end
    end
  end
end

