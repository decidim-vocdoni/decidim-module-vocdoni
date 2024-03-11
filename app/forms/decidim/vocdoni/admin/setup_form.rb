# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This class holds a form to setup elections from Decidim's admin panel.
      class SetupForm < Decidim::Form
        mimic :setup

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
            census_ready,
            time_before_validation,
            [:published, { link: router.publish_page_election_path(election) }, election.published_at.present?]
          ].freeze
        end

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

        def census_ready
          key = election.internal_census? ? :internal_census_ready_html : :census_ready

          [key, { link: router.election_census_path(election), **census_ready_validation_args }, census.ready_to_setup?]
        end

        private

        def router
          @router ||= EngineRouter.admin_proxy(election.component)
        end

        def time_before_minutes
          Decidim::Vocdoni.minimum_minutes_before_start
        end

        def time_before_validation
          if election.manual_start?
            [:manual_start, { link: router.edit_election_calendar_path(election), minutes: time_before_minutes }, true]
          else
            [:time_before, { link: router.edit_election_calendar_path(election), minutes: time_before_minutes }, election.minimum_minutes_before_start?]
          end
        end

        def census_ready_validation_args
          if election.internal_census?
            {
              link: router.election_census_path(election),
              verification_types: formatted_verification_types
            }
          else
            {
              link: router.election_census_path(election)
            }
          end
        end

        def formatted_verification_types
          if election.verification_types.empty?
            I18n.t("status.no_additional_authorizations", scope: "decidim.vocdoni.admin.census")
          else
            election.verification_types.map do |type|
              I18n.t("decidim.authorization_handlers.#{type}.name").downcase
            end.join(", ")
          end
        end
      end
    end
  end
end
