# frozen_string_literal: true

require "decidim/vocdoni/admin"
require "decidim/vocdoni/api"
require "decidim/vocdoni/engine"
require "decidim/vocdoni/admin_engine"
require "decidim/vocdoni/component"

module Decidim
  # This namespace holds the logic of the `Vocdoni` component. This component
  # allows users to create vocdoni in a participatory space.
  module Vocdoni
    include ActiveSupport::Configurable

    # Hash constant defining the Vocdoni API endpoints for each environment.
    API_ENDPOINTS = {
      "prd" => "https://api.vocdoni.net/v2",
      "stg" => "https://api-stg.vocdoni.net/v2",
      "dev" => "https://api-dev.vocdoni.net/v2"
    }.freeze

    # Public Setting that defines the maximum number of votes that can be
    # overwritten by the voter
    config_accessor :votes_overwrite_max do
      ENV.fetch("DECIDIM_VOCDONI_VOTES_OVERWRITE_MAX", 10).to_i
    end

    # Public Setting that defines how many minutes should the setup be run before the election starts
    config_accessor :minimum_minutes_before_start do
      ENV.fetch("VOCDONI_MINUTES_BEFORE_START", 10).to_i
    end

    # Public Setting that defines how long after the action of manually starting
    # an election will the start_time of an election will be setup
    # Some time is needed in order to comunicate the election to vocdoni,
    # send the configured data and set it to "paused" status
    config_accessor :manual_start_time_delay do
      ENV.fetch("VOCDONI_MANUAL_START_DELAY", "30").to_i.seconds
    end

    # Public Setting to configure the Vocdoni API enpoint
    # It can be "dev" or "stg"
    config_accessor :api_endpoint_env do
      ENV.fetch("VOCDONI_API_ENDPOINT_ENV", "stg")
    end

    # Public: Setting to configure the interruptible elections
    config_accessor :interruptible_elections do
      true
    end

    # Public: Returns the API endpoint URL based on the environment specified in the configuration.
    def self.api_endpoint_url
      API_ENDPOINTS[api_endpoint_env]
    end

    def self.api_endpoint_env
      return "stg" if config.api_endpoint_env.downcase == "stg"

      "dev"
    end

    def self.explorer_vote_domain
      "#{api_endpoint_env}.explorer.vote"
    end
  end
end
