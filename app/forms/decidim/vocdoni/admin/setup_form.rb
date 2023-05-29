# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This class holds a form to setup elections from Decidim's admin panel.
      class SetupForm < Decidim::Form
        mimic :setup

        attribute :vocdoni_election_id, String

        validate do
          validations.each do |message, t_args, valid|
            errors.add(message, I18n.t("steps.create_election.errors.#{message}", **t_args, scope: "decidim.vocdoni.admin")) unless valid
          end
        end

        def current_step; end

        def validations
          @validations ||= [
            [:minimum_questions, { link: router.election_questions_path(election) }, election.questions.any?],
            [:minimum_answers, { link: router.election_questions_path(election) }, election.minimum_answers?],
            [:published, { link: router.edit_election_path(election) }, election.published_at.present?],
            [:time_before, { link: router.edit_election_election_calendar_path(election, election_id: election.id), minutes: time_before_minutes },
             election.minimum_minutes_before_start?],
            [:census_ready, { link: router.election_census_path(election) }, census.ready_to_setup?]
          ].freeze
        end
        #
        # def messages
        #   @messages ||= validations.to_h do |message, t_args, _valid|
        #     [message, I18n.t("steps.create_election.requirements.#{message}", **t_args, scope: "decidim.vocdoni.admin")]
        #   end
        # end

        def messages
          @messages ||= validations.to_h do |message, t_args, _valid|
            [message, { message: I18n.t("steps.create_election.requirements.#{message}", **t_args, scope: "decidim.vocdoni.admin"), link: t_args[:link] }]
          end
        end

        def election
          @election ||= context[:election]
        end

        def census
          @census ||= CsvCensus::Status.new(election)
        end

        def main_button?
          true
        end

        private

        def router
          @router ||= EngineRouter.admin_proxy(election.component)
        end

        def time_before_minutes
          Decidim::Vocdoni.config.setup_minimum_minutes_before_start
        end
      end
    end
  end
end
