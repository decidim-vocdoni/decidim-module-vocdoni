# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This cell renders the results in real time
    # for a given instance of an Election
    class ElectionResultsRealtimeCell < Decidim::ViewModel
      def show
        render unless model.election_type["secret_until_the_end"] || model.finished?
      end

      def election_data
        @election_data ||= options[:election_data]
      end

      def election_results
        @election_results ||= election_data["result"]
      end
    end
  end
end
