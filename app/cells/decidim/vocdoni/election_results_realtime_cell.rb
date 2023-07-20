# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This cell renders the results in real time
    # for a given instance of an Election
    class ElectionResultsRealtimeCell < Decidim::ViewModel
      include Decidim::Vocdoni::Engine.routes.url_helpers

      def show
        render unless model.election_type["secret_until_the_end"] || !model.ongoing?
      end

      def election_url
        election_path(
          id: model.id,
          format: :json,
          component_id: current_component.id,
          assembly_slug: current_participatory_space.slug
        )
      end

      def election_data
        @election_data ||= options[:election_data]
      end

      def election_results
        @election_results ||= election_data["result"]
      end

      private

      def current_component
        model.component
      end

      def current_participatory_space
        current_component.participatory_space
      end
    end
  end
end
