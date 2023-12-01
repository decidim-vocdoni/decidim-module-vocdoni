# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A form to save all the Results in an Election
      class ResultsForm < Form
        def current_step; end

        def main_button?
          true
        end

        def election
          @election ||= context[:election]
        end
      end
    end
  end
end
