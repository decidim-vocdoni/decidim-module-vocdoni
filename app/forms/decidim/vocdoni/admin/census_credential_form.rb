# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A form to save the public key for a wallet from the Census
      # To be used with CensusCredentialsForm
      class CensusCredentialForm < Form
        mimic :voter

        attribute :email, String
        attribute :born_at, String
        attribute :wallet_address, String

        validates :wallet_address, presence: true
      end
    end
  end
end
