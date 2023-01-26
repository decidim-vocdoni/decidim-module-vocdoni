# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # Custom helpers for election steps on admin dashboard.
      #
      module StepsHelper
        def steps(current_step)
          step_class = "text-success"
          (["create_election"] + Decidim::Vocdoni::Election.statuses.keys).map do |step|
            if step == current_step
              step_class = "text-muted"
              [step, "text-warning"]
            else
              [step, step_class]
            end
          end
        end
      end
    end
  end
end
