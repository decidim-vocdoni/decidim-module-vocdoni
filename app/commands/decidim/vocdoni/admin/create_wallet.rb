# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user creates an Ethereum Wallet
      # from the admin panel.
      # The Wallet will be created in the frontend with ethers.js
      class CreateWallet < Decidim::Command
        def initialize(user)
          @organization = user.organization
          @user = user
        end

        # Creates the wallet if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        #
        # Returns nothing
        def call
          return broadcast(:invalid) unless private_key&.match?(/\A0x[a-fA-F0-9]*\z/)

          create_wallet!

          broadcast(:ok)
        end

        private

        attr_reader :organization, :user, :wallet

        def private_key
          token = "#{organization.id}-#{Rails.application.secret_key_base}"
          @private_key ||= Sdk.new(organization).deterministicWallet(token)["privateKey"]
        end

        def create_wallet!
          attributes = {
            organization: organization,
            private_key: private_key
          }

          @wallet = Decidim.traceability.create!(
            Wallet,
            user,
            attributes
          )
        end
      end
    end
  end
end
