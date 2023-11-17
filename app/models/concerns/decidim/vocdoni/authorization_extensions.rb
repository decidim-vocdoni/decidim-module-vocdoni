# frozen_string_literal: true

module Decidim
  module Vocdoni
    module AuthorizationExtensions
      extend ActiveSupport::Concern

      included do
        has_one :vocdoni_authorizations_data,
                class_name: "Decidim::Vocdoni::AuthorizationsData",
                dependent: :destroy

        after_update :add_to_vocdoni_queue, if: :saved_change_to_granted_at?
        after_destroy :clear_related_voters_from_census

        def add_to_vocdoni_queue
          elections_with_census_permissions.each do |election|
            next unless election.verification_types.include?(name) && granted_at.present?

            Decidim::Vocdoni::AuthorizationsData.find_or_create_by!(
              authorization: self,
              decidim_vocdoni_election_id: election.id
            ) do |authorization_data|
              authorization_data.processed = false
            end
          end
        end

        def clear_related_voters_from_census
          user = Decidim::User.find_by(id: decidim_user_id)

          elections_with_census_permissions.each do |election|
            Decidim::Vocdoni::Voter.clear(election) if Decidim::Vocdoni::Voter.exists?(email: user.email, election: election)
          end
        end

        private

        def elections_with_census_permissions
          Decidim::Vocdoni::Election.where(internal_census: true)
        end
      end
    end
  end
end
