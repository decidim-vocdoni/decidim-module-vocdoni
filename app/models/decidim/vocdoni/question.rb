# frozen_string_literal: true

module Decidim
  module Vocdoni
    # The data store for a Question in the Decidim::Vocdoni component
    class Question < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Traceable
      include Decidim::Loggable
      include VocdoniApiUtils

      belongs_to :election, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Election", inverse_of: :questions
      has_many :answers, foreign_key: "decidim_vocdoni_question_id", class_name: "Decidim::Vocdoni::Answer", inverse_of: :question, dependent: :destroy
      has_one :component, through: :election, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      default_scope { order(weight: :asc, id: :asc) }

      delegate :organization, to: :election

      def total_votes
        answers.sum(:votes)
      end

      def slug
        "question-#{id}"
      end

      # Make sure all the answers have numeric consecutive values
      def build_answer_values!
        answers.each_with_index do |answer, index|
          answer.update(value: index)
        end
      end

      # Vocdoni format is an array of [title, description, [{title:, value: }]
      def to_vocdoni
        [
          transform_locales(title),
          transform_locales(description),
          answers.map do |answer|
            {
              "title" => transform_locales(answer.title),
              "value" => answer.value.to_i
            }
          end
        ]
      end
    end
  end
end
