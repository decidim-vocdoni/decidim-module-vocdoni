# frozen_string_literal: true

module Decidim
  module Vocdoni
    class CensusUpdaterService
      def initialize(election, current_user_id, non_voter_ids)
        @election = election
        @current_user_id = current_user_id
        @non_voter_ids = non_voter_ids
      end

      def update_census
        return unless @election&.internal_census?

        user_data = @election.census_status.all_wallets
        return if user_data.blank?

        census_attributes = build_census_attributes
        raw_result = Sdk.new(@election.organization, @election).updateCensus(census_attributes, user_data)

        handle_sdk_response(raw_result)
      end

      private

      def build_census_attributes
        {
          id: @election.census_attributes["id"],
          identifier: @election.census_attributes["identifier"],
          address: @election.census_attributes["address"],
          privateKey: @election.census_attributes["private_key"],
          publicKey: @election.census_attributes["public_key"],
          electionId: @election.vocdoni_election_id
        }
      end

      def handle_sdk_response(raw_result)
        return Rails.logger.error("Error updating census: No response from Sdk") if raw_result.blank?

        result = JSON.parse(raw_result)
        if result["success"]
          attributes = {
            last_census_update_records_added: @non_voter_ids.count,
            census_last_updated_at: result["timestamp"]
          }
          current_user = Decidim::User.find_by(id: @current_user_id)
          Decidim.traceability.update!(@election, current_user, attributes, visibility: "all")
          Rails.logger.info("Census updated for election #{@election.id}, adding #{result["count"]} voters.")

          delete_technical_voter
        else
          Rails.logger.error("Error updating census: #{result["error"]}")
        end
      end

      def delete_technical_voter
        technical_voter_email = @election.technical_voter_email
        technical_voter = @election.voters.find_by(email: technical_voter_email)
        technical_voter&.destroy
        Rails.logger.info("Technical voter #{technical_voter_email} deleted successfully.") if technical_voter
      end
    end
  end
end
