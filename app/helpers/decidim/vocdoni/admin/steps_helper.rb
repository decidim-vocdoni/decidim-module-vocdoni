# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # Custom helpers for election steps on admin dashboard.
      #
      module StepsHelper
        def steps(current_step)
          step_class = "is-complete"

          status_for_step(current_step).map do |step|
            if step == current_step
              step_class = "text-muted"
              [step, "text-warning"]
            else
              [step, step_class]
            end
          end
        end

        def fix_it_button_with_icon(link, icon)
          link_to link, class: "button tiny" do
            "#{icon(icon)} #{I18n.t("decidim.vocdoni.admin.steps.create_election.errors.fix_it_text")}".html_safe
          end
        end

        def danger_zone_submit(form, action)
          ico, button_class = case action
                              when "start"
                                ["media-play", "primary"]
                              when "vote"
                                ["media-play", "success"]
                              when "paused"
                                ["media-pause", "warning"]
                              end
          text = t(action, scope: "decidim.vocdoni.admin.steps.danger_zone.action")
          text = "#{icon(ico, class: "icon--before")} #{text}".html_safe

          form.submit text, class: "button #{button_class}",
                            data: { confirm: t("confirm", scope: "decidim.vocdoni.admin.steps.danger_zone") }
        end

        private

        def status_for_step(current_step)
          status = ["create_election"] + Decidim::Vocdoni::Election.statuses.keys

          case current_step
          when "paused"
            status - ["canceled"]
          when "canceled"
            status - %w(paused vote_ended results_published)
          else
            status - %w(canceled paused)
          end
        end
      end
    end
  end
end
