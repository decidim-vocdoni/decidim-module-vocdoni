# frozen_string_literal: true

module Decidim
  module Vocdoni
    class VocdoniClient
      attr_reader :wallet, :api_endpoint_env

      def initialize(wallet:, api_endpoint_env:)
        @wallet = wallet
        @api_endpoint_env = api_endpoint_env
      end

      def fetch_election(vocdoni_election_id)
        fetch_from_api("/elections/#{vocdoni_election_id}")
      end

      private

      def fetch_from_api(path)
        url = "#{base_url}#{path}"
        response = Faraday.get(url)

        JSON.parse(response.body) if response.success? && response.body.present?
      end

      def base_url
        Decidim::Vocdoni.api_endpoint_url(api_endpoint_env)
      end
    end
  end
end
