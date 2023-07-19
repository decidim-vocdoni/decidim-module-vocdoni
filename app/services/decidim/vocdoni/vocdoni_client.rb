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
        url = "#{base_url}/elections/#{vocdoni_election_id}"
        response = Faraday.get(url)

        JSON.parse(response.body) if response.success? && response.body.present?
      end

      private

      def base_url
        case Decidim::Vocdoni.api_endpoint_env
        when "prd"
          "https://api.vocdoni.net/v2"
        when "stg"
          "https://api-stg.vocdoni.net/v2"
        else
          "https://api-dev.vocdoni.net/v2"
        end
      end
    end
  end
end
