# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CreateVocdoniElectionJob < ApplicationJob
        def perform(election_id)
          @election_id = election_id

          Rails.logger.info "CreateVocdoniElectionJob: Creating election #{election_id} at Vocdoni env #{Decidim::Vocdoni.api_endpoint_env}"

          # json format
          begin
            vocdoni_id = sdk.createElection(election.to_vocdoni, election.questions_to_vocdoni, election.census_status.all_wallets)
            election.update(vocdoni_election_id: vocdoni_id)
            Rails.logger.info "CreateVocdoniElectionJob: Election #{election_id} created at Vocdoni with id #{vocdoni_id}"
          rescue Sdk::NodeError => e
            Rails.logger.error "CreateVocdoniElectionJob: Error creating election #{election_id} at Vocdoni: #{e.message}"
          end
        end

        private

        def sdk
          @sdk ||= Sdk.new(organization, election)
        end

        def organization
          @organization ||= election&.organization
        end

        def election
          @election ||= Decidim::Vocdoni::Election.find_by(id: @election_id)
        end
      end
    end
  end
end
