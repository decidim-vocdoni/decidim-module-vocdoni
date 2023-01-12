# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This class holds a Form to create an Ethereum Wallet
      class WalletForm < Decidim::Form
        mimic :wallet

        attribute :private_key, String

        validates :private_key, presence: true
        validates :private_key, length: { in: 40..70 }
        validates :private_key, format: /\A0x[a-zA-Z0-9]*\z/
      end
    end
  end
end
