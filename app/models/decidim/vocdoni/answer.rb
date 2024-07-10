# frozen_string_literal: true

module Decidim
  module Vocdoni
    # The data store for an Answer in the Decidim::Vocdoni component
    class Answer < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::Traceable
      include Decidim::Loggable

      delegate :organization, :participatory_space, to: :component

      belongs_to :question, foreign_key: "decidim_vocdoni_question_id", class_name: "Decidim::Vocdoni::Question", inverse_of: :answers, counter_cache: true
      has_one :election, through: :question, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Election"
      has_one :component, through: :election, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      default_scope { order(weight: :asc, id: :asc) }

      # A votes percentage relative to the question
      # Returns a Float.
      def votes_percentage
        return unless question.total_votes.positive? && !votes.nil?

        @votes_percentage ||= (votes.to_f / question.total_votes * 100.0).round(2)
      end

      def slug
        "answer-#{id}"
      end
    end
  end
end
