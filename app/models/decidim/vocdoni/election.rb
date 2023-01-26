# frozen_string_literal: true

module Decidim::Vocdoni
  class Election < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Resourceable
    include Decidim::HasComponent
    include Decidim::TranslatableResource
    include Decidim::Publicable
    include Decidim::Traceable

    enum status: [:created, :vote, :vote_ended, :tally_started, :tally_ended, :results_published].index_with(&:to_s)

    component_manifest_name "vocdoni"

    has_many :questions, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Question", inverse_of: :election, dependent: :destroy

    translatable_fields :title, :description

    def self.log_presenter_class_for(_log)
      Decidim::Vocdoni::AdminLog::ElectionPresenter
    end

    # Public: Checks if the election started
    #
    # Returns a boolean.
    def started?
      start_time <= Time.current
    end

    # Public: Checks if the election finished
    #
    # Returns a boolean.
    def finished?
      end_time < Time.current
    end

    # Public: Checks if the election ongoing now
    #
    # Returns a boolean.
    def ongoing?
      started? && !finished?
    end

    # Public: Checks if the election has a blocked_at value
    #
    # Returns a boolean.
    def blocked?
      blocked_at.present?
    end

    # Public: Checks if the number of answers are minimum 2 for each question
    #
    # Returns a boolean.
    def minimum_answers?
      questions.any? && questions.all? { |question| question.answers.size > 1 }
    end

    # Public: Gets the voting period status of the election
    #
    # Returns one of these symbols: upcoming, ongoing or finished
    def voting_period_status
      if finished?
        :finished
      elsif started?
        :ongoing
      else
        :upcoming
      end
    end
  end
end
