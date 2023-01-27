# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # A form to save the all the public keys' wallets from the Census
      # To be used with CensusCredentialForm
      class CensusCredentialsForm < Form
        attribute :credentials, Array[CensusCredentialForm]
      end
    end
  end
end
