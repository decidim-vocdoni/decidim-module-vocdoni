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
        return unless election && election.internal_census?

        user_data = authorizations.filter_map do |authorization_data|
          user = Decidim::User.find_by(id: authorization_data.authorization.decidim_user_id)
          if user && election.verification_types.include?(authorization_data.authorization.name)
            authorization_data.update(processed: true)
            [user.email.downcase, token_for_voter(user.email, election.id)]
          end
        end

        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Vocdoni::Voter.insert_all(election, user_data) if user_data.any?
        # rubocop:enable Rails/SkipsModelValidations

        # rubocop:disable Rails/Output
        puts "Processed authorization data for election with id: #{election.id}"
        puts "Election voters count: #{election.voters.count}"
        # rubocop:enable Rails/Output

        authorizations.select(&:processed).each(&:destroy)
      end

      def token_for_voter(email, election_id)
        "#{email}-#{election_id}-#{SecureRandom.hex(16)}"
      end
    end
  end
end
