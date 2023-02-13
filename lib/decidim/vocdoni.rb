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

    # Public Setting to configure the Vocdoni API enpoint
    # It can be "dev" or "stg"
    config_accessor :api_endpoint_env do
      "dev"
    end

    def self.explorer_vote_domain
      "#{api_endpoint_env}.explorer.vote"
    end
  end
end
