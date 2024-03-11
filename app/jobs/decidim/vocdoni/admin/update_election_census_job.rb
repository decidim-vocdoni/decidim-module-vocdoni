# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class UpdateElectionCensusJob < ApplicationJob
        queue_as :default

        def perform(election_id, non_voter_ids, current_user_id)
          election = Decidim::Vocdoni::Election.find_by(id: election_id)
          return unless election&.internal_census?

          VoterService.verify_and_insert(election, non_voter_ids)

          CreateVoterWalletsJob.perform_now(election_id)

          CensusUpdaterService.new(election, current_user_id, non_voter_ids).update_census if all_voters_processed?(election)
        end

        private

        def election
          @election ||= Decidim::Vocdoni::Election.find_by(id: @election_id)
        end

        def current_user
          @current_user ||= Decidim::User.find_by(id: @current_user_id)
        end

        def all_voters_processed?(election)
          election.voters.where(in_vocdoni_census: false).empty?
        end
      end
    end
  end
end
