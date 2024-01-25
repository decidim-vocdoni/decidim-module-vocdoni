# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class UpdateElectionCensusJob < ApplicationJob
        queue_as :default

        def perform(election_id)
          @election_id = election_id
          return unless election && election.internal_census?

          update_census!
        end

        private

        def election
          @election ||= Decidim::Vocdoni::Election.find_by(id: @election_id)
        end

        def update_census!
          user_data = election.census_status.all_wallets
          census_attributes = {
            identifier: election.census_attributes["identifier"],
            address: election.census_attributes["address"],
            privateKey: election.census_attributes["private_key"],
            publicKey: election.census_attributes["public_key"]
          }
          Sdk.new(election.organization, election).updateCensus(census_attributes, user_data) if user_data.present?
        end
      end
    end
  end
end
