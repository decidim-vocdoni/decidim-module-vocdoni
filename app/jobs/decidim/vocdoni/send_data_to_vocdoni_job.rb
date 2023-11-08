# frozen_string_literal: true

module Decidim
  module Vocdoni
    class SendDataToVocdoniJob < ApplicationJob
      queue_as :send_data_to_vocdoni

      def perform
        election_authorization_data = group_authorization_data_by_election

        election_authorization_data.each do |election_id, authorizations|
          process_election_authorizations(election_id, authorizations)
        end
      end

      private

      def group_authorization_data_by_election
        AuthorizationsData.where(processed: false).each_with_object({}) do |authorization_data, hash|
          (hash[authorization_data.decidim_vocdoni_election_id] ||= []) << authorization_data
        end
      end

      def process_election_authorizations(election_id, authorizations)
        election = Decidim::Vocdoni::Election.find_by(id: election_id)
        return unless election && election.census_type == "census_permissions"

        user_emails = authorizations.filter_map do |authorization_data|
          user = Decidim::User.find_by(id: authorization_data.authorization.decidim_user_id)
          if user && election.verification_types.include?(authorization_data.authorization.name)
            authorization_data.update(processed: true)
            user.email
          end
        end

        Decidim::Vocdoni::Voter.insert_participants_with_permissions(election, user_emails, "verified") if user_emails.any?

        Rails.logger.debug { "Processed authorization data for election with id: #{election.id}" }
        Rails.logger.debug { "Election voters count: #{election.voters.count}" }

        authorizations.select(&:processed).each(&:destroy)
      end
    end
  end
end
