# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This cell renders the election card for an instance of an election
    # the default size is the Grid (:g) election card
    class ElectionCell < Decidim::ViewModel
      include ElectionCellsHelper
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/vocdoni/election_g"
      end
    end
  end
end
