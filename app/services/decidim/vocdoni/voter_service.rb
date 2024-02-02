# frozen_string_literal: true

module Decidim
  module Vocdoni
    class VoterService
      def self.verify_and_insert(election, non_voter_ids)
        verified_users = fetch_verified_users(election, non_voter_ids)

        # rubocop:disable Rails/SkipsModelValidations
        Voter.insert_all(election, verified_users) if verified_users.any?
        # rubocop:enable Rails/SkipsModelValidations
      end

      def self.fetch_verified_users(election, non_voter_ids)
        Decidim::User.where(id: non_voter_ids).map do |user|
          [user.email, "#{user.email}-#{election.id}-#{SecureRandom.hex(16)}"]
        end
      end
    end
  end
end
