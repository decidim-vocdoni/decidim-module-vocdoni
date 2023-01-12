# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command is executed when the user creates an Ethereum Wallet
      # from the admin panel.
      # The Wallet will be created in the frontend with ethers.js
      class CreateWallet < Decidim::Command
        def initialize(form)
          @form = form
        end

        # Creates the wallet if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        #
        # Returns nothing
        def call
          return broadcast(:invalid) if form.invalid?

          create_wallet!

          broadcast(:ok)
        end

        private

        attr_reader :form, :wallet

        def create_wallet!
          attributes = {
            organization: form.current_organization,
            private_key: form.private_key
          }

          @wallet = Decidim.traceability.create!(
            Wallet,
            form.current_user,
            attributes
          )
        end
      end
    end
  end
end
