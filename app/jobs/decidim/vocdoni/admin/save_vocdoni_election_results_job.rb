# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class SaveVocdoniElectionResultsJob < VocdoniSdkBaseJob
        def perform(election_id)
          @election_id = election_id

          Rails.logger.info "SaveVocdoniElectionResultsJob: Saving results for election #{election_id} at Vocdoni env #{Decidim::Vocdoni.api_endpoint_env}"

          # json format
          begin
            @metadata = sdk.electionMetadata
            update_results
            Rails.logger.info "SaveVocdoniElectionResultsJob: Results for election #{election_id}: #{results}"
          rescue Sdk::NodeError => e
            Rails.logger.error "SaveVocdoniElectionResultsJob: Error updating results for election #{election_id} at Vocdoni: #{e.message}"
          end
        end

        attr_reader :metadata

        private

        def update_results
          return unless results

          election.questions.each_with_index do |question, idx|
            answer_results = results[idx]
            next unless answer_results

            question.answers.each do |answer|
              next unless answer.value.is_a?(Integer)

              answer.update(votes: answer_results[answer.value])
            end
          end
        end

        def results
          @results ||= metadata["results"] if metadata
        end
      end
    end
  end
end
