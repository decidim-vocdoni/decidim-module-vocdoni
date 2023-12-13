# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CreateVoterWalletsJob < VocdoniSdkBaseJob
        def perform(election_id)
          @election_id = election_id

          count = voters.count
          ok = 0
          Rails.logger.info "CreateVoterWalletsJob: Processing #{count} voters for election #{election_id}"
          voters.find_each do |voter|
            voter.wallet_address = sdk.deterministicWallet([voter.email, voter.token])["address"]
            if voter.save
              ok += 1
            else
              Rails.logger.error "CreateVoterWalletsJob: Error updating the private key for voter #{voter.id}"
            end
          end
          Rails.logger.info "CreateVoterWalletsJob: Succesfully processed #{ok} voters. #{count - ok} errors for election #{election_id}"
        end

        private

        def voters
          Decidim::Vocdoni::Voter.inside(election)
        end
      end
    end
  end
end
