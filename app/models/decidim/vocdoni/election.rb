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

    enum status: [:created, :vote, :paused, :vote_ended, :results_published, :canceled].index_with(&:to_s)

    component_manifest_name "vocdoni"

    has_many :questions, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Question", inverse_of: :election, dependent: :destroy
    has_many :voters, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Voter", inverse_of: :election, dependent: :destroy

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

    # Public: Checks if the election start_time is minimum some minutes later than the present time
    #
    # Returns a boolean.
    def minimum_minutes_before_start?
      start_time > (Time.zone.at(Decidim::Vocdoni.config.setup_minimum_minutes_before_start.minutes.from_now))
    end

    # Public: Checks if all the Answers related to an Election (through Questions) have a value
    #
    # Returns a boolean
    def answers_have_values?
      questions.map(&:answers).flatten.pluck(:value).none? nil
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

    # Public: the Vocdoni's Explorer Vote platform URL
    #
    # Returns a string with the full URL
    def explorer_vote_url
      "https://#{Decidim::Vocdoni.explorer_vote_domain}/processes/show/#/#{vocdoni_election_id}"
    end
  end
end
