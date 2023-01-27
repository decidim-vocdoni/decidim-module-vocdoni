# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A form to save the public key for a wallet from the Census
      # To be used with CensusCredentialsForm
      class CensusCredentialForm < Form
        mimic :voter

        attribute :email
        attribute :born_at
        attribute :wallet_public_key
      end
    end
  end
end
