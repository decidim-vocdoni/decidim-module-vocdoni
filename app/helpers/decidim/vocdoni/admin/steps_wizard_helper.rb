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

        def tab_link_class(tab_name, election)
          case tab_name
          when "questions"
            election.present? ? "" : "disabled"
          when "census"
            census_ready_or_minimum_answers?(election) ? "" : "disabled"
          when "results"
            census_ready? ? "" : "disabled"
          when "publish"
            publishable?(election) ? "" : "disabled"
          else
            ""
          end
        end

        def question_with_link(question, election)
          link = link_to("\"#{translated_attribute(question&.title)}\"", edit_election_question_path(election, question))
          t("for_question_html", question: link, scope: "decidim.vocdoni.admin.answers.index")
        end

        private

        def census_ready_or_minimum_answers?(election)
          election&.minimum_answers? || census_status == "ready"
        end

        def census_ready?
          census_status == "ready"
        end

        def times_set?(election)
          election.start_time.present? && election.end_time.present?
        end

        def publishable?(election)
          census_ready? && times_set?(election)
        end

        def census_status
          @census_status ||= CsvCensus::Status.new(election)&.name
        end
      end
    end
  end
end
