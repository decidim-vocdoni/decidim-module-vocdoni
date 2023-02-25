# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A form to save all the Results in an Election
      class ResultsForm < Form
        attribute :results, Array[Hash]

        validate :results_not_empty

        def current_step; end

        def main_button?
          true
        end

        def election
          @election ||= context[:election]
        end

        private

        # If all the votes are 0, then we probably didn't fetch
        # correctly the results, and the administrator need to retry
        def results_not_empty
          if results_are_all_zero?
            errors.add(:invalid_results, I18n.t("error.invalid", scope: "decidim.vocdoni.admin.steps.vote_ended"))
          end
        end

        def results_are_all_zero?
          results.map{ |questions| questions[:votes].to_i }.all? 0
        end
      end
    end
  end
end
