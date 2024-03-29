# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows the create an Ethereum Wallet.
      class WalletsController < Admin::ApplicationController
        helper Decidim::ApplicationHelper

        def new
          enforce_permission_to :create, :wallet
        end

        def create
          enforce_permission_to :create, :wallet

          CreateWallet.call(current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("wallet.create.success", scope: "decidim.vocdoni.admin")
              redirect_to redirect_location
            end
            on(:invalid) do
              flash.now[:alert] = I18n.t("wallet.create.invalid", scope: "decidim.vocdoni.admin")
              render action: "new"
            end
          end
        end

        private

        def redirect_location
          if (location = session.delete(:redirect_back))
            EngineRouter.admin_proxy(current_component).election_steps_path(location)
          else
            EngineRouter.admin_proxy(current_component).root_path
          end
        end
      end
    end
  end
end
