# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # Custom helpers for election steps on admin dashboard.
      #
      module StepsHelper
        def steps(current_step)
          step_class = "text-success"

          status_for_step(current_step).map do |step|
            if step == current_step
              step_class = "text-muted"
              [step, "text-warning"]
            else
              [step, step_class]
            end
          end
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
