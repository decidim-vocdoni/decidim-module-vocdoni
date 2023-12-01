# frozen_string_literal: true

module Decidim
  module Vocdoni
    class Api
      attr_reader :vocdoni_election_id

      def initialize(vocdoni_election_id:)
        @vocdoni_election_id = vocdoni_election_id
      end

      def fetch_election
        fetch_from_api("/elections/#{vocdoni_election_id}")
      end

      private

      def fetch_from_api(path)
        url = "#{base_url}#{path}"
        response = Faraday.get(url)

        JSON.parse(response.body) if response.success? && response.body.present?
      end

      def base_url
        Decidim::Vocdoni.api_endpoint_url
      end
    end
  end
end
