# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # Custom helpers, scoped to the vocdoni admin engine.
      #
      module StepsWizardHelper
        def tab_class(tab_name, active_class)
          "tabs-title #{active_class == tab_name ? "is-active" : ""}"
        end

        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def tab_link_class(tab_name, election)
          case tab_name
          when "questions"
            election.present? ? "" : "disabled"
          when "census"
            election&.minimum_answers? || census_status == "ready" ? "" : "disabled"
          when "results"
            census_status == "ready" ? "" : "disabled"
          when "publish"
            election.start_time.present? && election.end_time.present? && census_status == "ready" ? "" : "disabled"
          else
            ""
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def census_status
          @census_status ||= CsvCensus::Status.new(election)&.name
        end
      end
    end
  end
end
