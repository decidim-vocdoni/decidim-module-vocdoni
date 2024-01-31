# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class UpdateElectionCensusJob < ApplicationJob
        queue_as :default

        def perform(election_id, non_voter_ids)
          @election_id = election_id
          @non_voter_ids = non_voter_ids

          return unless election && election.internal_census?

          # rubocop:disable Rails/SkipsModelValidations
          Voter.insert_all(@election, fetch_verified_users(non_voter_ids)) if fetch_verified_users(non_voter_ids).present?
          # rubocop:enable Rails/SkipsModelValidations

          CreateVoterWalletsJob.perform_later(election_id)

          if all_voters_processed?
            update_census!
          else
            self.class.set(wait: 10.seconds).perform_later(election_id, non_voter_ids)
          end
        end

        private

        def fetch_verified_users(non_voter_ids)
          non_voter = Decidim::User.where(id: non_voter_ids)

          non_voter.map do |user|
            [user.email, token_for_voter(user.email)]
          end
        end

        def token_for_voter(email)
          "#{email}-#{@election.id}-#{SecureRandom.hex(16)}"
        end

        def election
          @election ||= Decidim::Vocdoni::Election.find_by(id: @election_id)
        end

        def all_voters_processed?
          election.voters.where(in_vocdoni_census: false).empty?
        end

        def update_census!
          user_data = election.census_status.all_wallets
          census_attributes = {
            identifier: election.census_attributes["identifier"],
            address: election.census_attributes["address"],
            privateKey: election.census_attributes["private_key"],
            publicKey: election.census_attributes["public_key"],
            electionId: election.vocdoni_election_id
          }
          byebug
          begin
            Sdk.new(election.organization, election).updateCensus(census_attributes, user_data) if user_data.present?
            puts "Census updated for election #{election.id}, adding #{user_data.count} voters, USER_DATA: #{user_data}"
          rescue => e
            puts "Error updating census: #{e}"
          end
        end
      end
    end
  end
end
