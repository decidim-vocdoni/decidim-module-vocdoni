# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This type represents an election Voter.
    class VocdoniVoterType < Decidim::Api::Types::BaseObject
      description "A voter for an election"

      field :wallet_public_key, GraphQL::Types::String, "The wallet's public key of this voter", null: false, camelize: false
    end
  end
end
