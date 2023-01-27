# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when we're saving the Wallet (aka Credential)
      # in a census.
      class CreateCensusCredentials < Decidim::Command
        def initialize(form, election)
          @form = form
          @election = election
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          ActiveRecord::Base.transaction do
            @form.credentials.each do |credential|
              CsvDatum
                .find_by(election: @election, email: credential.email)
                .update(wallet_public_key: credential.wallet_public_key)
            end
          end

          broadcast(:ok)
        end
      end
    end
  end
end
