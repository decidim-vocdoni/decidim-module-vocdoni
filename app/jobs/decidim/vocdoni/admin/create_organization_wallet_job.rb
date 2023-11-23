# frozen_string_literal: true

require "node-runner"

module Decidim
  module Vocdoni
    module Admin
      class CreateOrganizationWalletJob < ApplicationJob
        def perform(organization_id)
          @organization = Decidim::Organization.find(organization_id)
          @form = WalletForm.from_params(private_key: address).with_context(current_organization: organization)
          CreateWallet.call(@form) do
            on(:ok) do
              Rails.logger.info "Wallet created for #{organization.id}"
            end
            on(:invalid) do
              Rails.logger.error "ERROR CREATING ORGANIZATION WALLET #{form.errors.full_messages}"
            end
          end

        end
        
        private

        attr_reader :organization, :form

        def address
          @address ||= begin
            javascript = File.read(File.join(Decidim::Vocdoni::Engine.root, "node-wrapper/index.js"))
            runner = NodeRunner.new(javascript)
            runner.randomWallet
            # a deterministic wallet may be better:
            # runner.deterministicWallet("#{organization_id}-#{Rails.application.secret_key_base}")
          end
        end
      end
    end
  end
end