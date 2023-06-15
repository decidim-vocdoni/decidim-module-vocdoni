# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # Custom helpers, scoped to the vocdoni admin engine.
      #
      module StepsWizardHelper
        def tab_class(tab_name, active_class)
          css_classes = ["tabs-title"]
          css_classes << "is-active" if active_class == tab_name
          css_classes.join(" ")
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

        def question_with_link(question, election)
          link = link_to("\"#{translated_attribute(question&.title)}\"", edit_election_question_path(election, question))
          t("for_question", question: link, scope: "decidim.vocdoni.admin.answers.index")
        end
      end
    end
  end
end
