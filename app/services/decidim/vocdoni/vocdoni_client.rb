# frozen_string_literal: true

module Decidim
  module Vocdoni
    class VocdoniClient
      API_ENDPOINTS = {
        "prd" => "https://api.vocdoni.net/v2",
        "stg" => "https://api-stg.vocdoni.net/v2",
        "dev" => "https://api-dev.vocdoni.net/v2"
      }.freeze

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
        API_ENDPOINTS[api_endpoint_env]
      end
    end
  end
end
