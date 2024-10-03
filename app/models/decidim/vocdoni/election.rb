# frozen_string_literal: true

module Decidim::Vocdoni
  class Election < ApplicationRecord
    include Decidim::FilterableResource
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Resourceable
    include Decidim::HasComponent
    include Decidim::TranslatableResource
    include Decidim::Publicable
    include Decidim::Traceable
    include VocdoniApiUtils

    enum status: [:created, :vote, :paused, :vote_ended, :results_published, :canceled].index_with(&:to_s)

    component_manifest_name "vocdoni"

    has_many :questions, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Question", inverse_of: :election, dependent: :destroy
    has_many :voters, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Voter", inverse_of: :election, dependent: :destroy

    scope :active, lambda {
      where("start_time <= ?", Time.current)
        .where("end_time >= ?", Time.current)
    }

    scope :upcoming, lambda {
      where("start_time > ?", Time.current)
        .where("end_time > ?", Time.current)
    }

    scope :finished, lambda {
      where("start_time < ?", Time.current)
        .where("end_time < ?", Time.current)
    }

    scope_search_multi :with_any_date, [:active, :upcoming, :finished]

    translatable_fields :title, :description

    def self.log_presenter_class_for(_log)
      Decidim::Vocdoni::AdminLog::ElectionPresenter
    end

    # Public: Checks if the election started
    #
    # Returns a boolean.
    def started?
      return false if status.nil?
      return false if start_time.nil?

      start_time <= Time.current
    end

    # Public: Checks if the election finished
    #
    # Returns a boolean.
    def finished?
      return false if status.nil?
      return true if canceled?
      return true if vote_ended?
      return true if results_published?

      end_time < Time.current
    end

    def misconfigured?
      !status.nil? && vocdoni_election_id.blank?
    end

    # Public: Checks if the election ongoing now
    #
    # Returns a boolean.
    def ongoing?
      started? && !paused? && !finished?
    end

    # Public: Checks if the election has a blocked_at value
    #
    # Returns a boolean.
    def blocked?
      blocked_at.present?
    end

    def auto_start?
      start_time.present?
    end

    def manual_start?
      !auto_start?
    end

    def interruptible?
      election_type&.fetch("interruptible", true)
    end

    def dynamic_census?
      election_type&.fetch("dynamic_census", false)
    end

    def secret_until_the_end?
      election_type&.fetch("secret_until_the_end", false)
    end

    def anonymous?
      election_type&.fetch("anonymous", false)
    end

    # Public: Checks if the number of answers are minimum 2 for each question
    #
    # Returns a boolean.
    def minimum_answers?
      questions.any? && questions.all? { |question| question.answers.size > 1 }
    end

    # Public: Checks if the election is ready for the questions step
    #
    # Returns a boolean.
    def ready_for_questions_form?
      present?
    end

    # Public: Checks if the start and end times for the election are set.
    #
    # Returns a boolean indicating if both the start time or manual_start and end time are present.
    def times_set?
      (start_time.present? || manual_start?) && end_time.present?
    end

    # Public: Checks if the census status for the election is "ready".
    #
    # Returns a boolean indicating if the census status equals "ready" or if it's an internal census selection and there are not verification types or voters.
    def census_ready?
      census_status&.name == "ready" || (internal_census? && verification_types.empty?) || (internal_census? && voters.empty?)
    end

    # Public: Checks if the election is ready for the census step
    #
    # Returns a boolean.
    def ready_for_census_form?
      minimum_answers?
    end

    # Public: Checks if the election is ready for the calendar step
    #
    # Returns a boolean.
    def ready_for_calendar_form?
      census_ready? && ready_for_census_form?
    end

    # Public: Checks if the election is ready for the publish step
    #
    # Returns a boolean.
    def ready_for_publish_form?
      ready_for_calendar_form? && times_set?
    end

    # Public: Checks if the election start_time is minimum some minutes later than the present time
    #
    # Returns a boolean.
    def minimum_minutes_before_start?
      return unless start_time

      start_time > (Time.zone.at(Decidim::Vocdoni.minimum_minutes_before_start.minutes.from_now))
    end

    # Public: Checks if all the Answers related to an Election (through Questions) have a value
    #
    # Returns a boolean
    def answers_have_values?
      questions.map(&:answers).flatten.pluck(:value).none? nil
    end

    # Public: Checks if there are votes set in the answers
    def answers_have_votes?
      questions.map(&:answers).flatten.pluck(:votes).any? Integer
    end

    # Public: Checks if the election has all results correctly defined
    def answers_have_results?
      questions.map(&:answers).flatten.pluck(:votes).none? nil
    end

    # Public: Gets the voting period status of the election
    #
    # Returns one of these symbols: upcoming, ongoing or finished
    def voting_period_status
      if paused?
        :paused
      elsif canceled?
        :canceled
      elsif finished?
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

    def build_answer_values!
      questions.each(&:build_answer_values!)
    end

    # Public: the Vocdoni's format to create a new election
    # @see https://developer.vocdoni.io/sdk/tutorial
    # The process to create an election still needs to add the keys "census" and "questions"
    # This is done using the Vocdoni SDK
    def to_vocdoni
      {
        "title" => transform_locales(title),
        "description" => transform_locales(description),
        "header" => photo&.attached_uploader(:file)&.url(host: organization.host).to_s,
        "streamUri" => stream_uri,
        "startDate" => start_time&.iso8601,
        "endDate" => end_time.iso8601,
        "electionType" => {
          # For the moment, we consider all censuses dynamic so admins can update them
          "dynamicCensus" => true,
          "interruptible" => interruptible?,
          "secretUntilTheEnd" => secret_until_the_end?,
          "anonymous" => anonymous?,
          "metadata" => { "encrypted" => false, "password" => nil }
        },
        "voteType" => {
          # uniqueChoices: false, # if the choices are unique when voting
          # costFromWeight: false, # for cuadrating voting
          # costExponent: 10000, # for cuadrating voting
          "maxVoteOverwrites" => Decidim::Vocdoni.votes_overwrite_max.to_i
        }
      }
    end

    def census_status
      @census_status ||= CsvCensus::Status.new(self)
    end

    def questions_to_vocdoni
      questions.map(&:to_vocdoni)
    end

    # Technical voter e-mail is used when the internal census is without voters
    def technical_voter_email
      "technical_voter_election_#{id}@techvoters.example.com"
    end

    # Create i18n ransackers for :title and :description.
    # Create the :search_text ransacker alias for searching from both of these.
    ransacker_i18n_multi :search_text, [:title, :description]

    def self.ransackable_scopes(_auth_object = nil)
      [:with_any_date]
    end
  end
end
