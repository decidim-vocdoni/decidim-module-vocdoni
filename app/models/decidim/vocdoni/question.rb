# frozen_string_literal: true

module Decidim
  module Vocdoni
    # The data store for a Question in the Decidim::Vocdoni component
    class Question < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :election, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Election", inverse_of: :questions
      has_many :answers, foreign_key: "decidim_vocdoni_question_id", class_name: "Decidim::Vocdoni::Answer", inverse_of: :question, dependent: :destroy
      has_one :component, through: :election, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      default_scope { order(weight: :asc, id: :asc) }

      def slug
        "question-#{id}"
      end
    end
  end
end
