# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      module StepsWizardHelper
        def tab_class(tab_name, active_class)
          active_class == tab_name ? "tabs-title is-active" : "tabs-title"
        end

        def tab_link_class(tab_name, election)
          case tab_name
          when "questions"
            css_class_for(election.ready_for_questions_form?)
          when "census"
            css_class_for(election.ready_for_census_form?)
          when "calendar"
            css_class_for(election.ready_for_calendar_form?)
          when "publish"
            css_class_for(election.ready_for_publish_form?)
          else
            ""
          end
        end

        def question_with_link(question, election)
          link = link_to("\"#{translated_attribute(question&.title)}\"", edit_election_question_path(election, question))
          t("for_question_html", question: link, scope: "decidim.vocdoni.admin.answers.index")
        end

        def tabs_info
          {
            "basic_info" => { path: edit_election_path(election), translation: "basic_info" },
            "questions" => { path: election_questions_path(election), translation: "questions" },
            "census" => { path: election_census_path(election), translation: "census" },
            "calendar" => { path: edit_election_calendar_path(election), translation: "results" },
            "publish" => { path: publish_page_election_path(election), translation: "publish" }
          }
        end

        private

        def css_class_for(condition)
          condition ? "" : "disabled"
        end
      end
    end
  end
end
