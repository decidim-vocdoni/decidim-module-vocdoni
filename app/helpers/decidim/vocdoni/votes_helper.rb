# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Custom helpers for the voting booth views.
    #
    module VotesHelper
      def ordered_answers(question)
        question.answers.sort_by { |answer| [answer.weight, answer.id] }
      end

      def more_information?(answer)
        translated_attribute(answer.description).present?
      end
    end
  end
end
