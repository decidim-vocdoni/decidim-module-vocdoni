# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CreateVocdoniElectionJob < VocdoniSdkBaseJob
        def perform(election_id)
          @election_id = election_id

          Rails.logger.info "CreateVocdoniElectionJob: Creating election #{election_id} at Vocdoni env #{Decidim::Vocdoni.api_endpoint_env}"

          # json format
          begin
            election.build_answer_values!
            @vocdoni_id = sdk.createElection(election.to_vocdoni, election.questions_to_vocdoni, election.census_status.all_wallets)
            update_election
            Rails.logger.info "CreateVocdoniElectionJob: Election #{election_id} created at Vocdoni with id #{vocdoni_id}"
          rescue Sdk::NodeError => e
            Rails.logger.error "CreateVocdoniElectionJob: Error creating election #{election_id} at Vocdoni: #{e.message}"
          end
        end

        attr_reader :vocdoni_id

        private

        def update_election
          election.vocdoni_election_id = vocdoni_id
          election.save!
          # set "paused" in vocdoni but not in decidim, this way we can simulate a "manual start"
          # Vocdoni does not provide an "idle" status, so we use "paused" to simulate it
          sdk.pauseElection if election.manual_start?
        end
      end
    end
  end
end
