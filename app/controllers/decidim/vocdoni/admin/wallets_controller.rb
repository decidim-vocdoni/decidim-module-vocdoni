# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows the create an Ethereum Wallet.
      class WalletsController < Admin::ApplicationController
        helper Decidim::ApplicationHelper

        def new
          enforce_permission_to :create, :wallet
          @form = form(WalletForm).instance
        end

        def create
          enforce_permission_to :create, :wallet
          CreateOrganizationWalletJob.perform_now(current_organization.id)
          redirect_to EngineRouter.admin_proxy(current_component).election_steps_path(location)
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
