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
            [:minimum_photos, {}, election.photos.any?],
            [:minimum_questions, {}, election.questions.any?],
            [:minimum_answers, {}, election.minimum_answers?],
            [:published, {}, election.published_at.present?],
            [:component_published, {}, election.component.published?],
            [:participatory_space_published, {}, election.participatory_space.published?],
            [:census_ready, {}, census.ready_to_setup?]
          ].freeze
        end

        def messages
          @messages ||= validations.to_h do |message, t_args, _valid|
            [message, I18n.t("steps.create_election.requirements.#{message}", **t_args, scope: "decidim.vocdoni.admin")]
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
      end
    end
  end
end
