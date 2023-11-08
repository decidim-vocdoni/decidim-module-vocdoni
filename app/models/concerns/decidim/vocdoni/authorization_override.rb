# frozen_string_literal: true

module Decidim
  module Vocdoni
    module AuthorizationOverride
      extend ActiveSupport::Concern

      included do
        has_one :vocdoni_authorizations_data,
                class_name: "Decidim::Vocdoni::AuthorizationsData",
                dependent: :destroy

        after_update :add_to_vocdoni_queue, if: :saved_change_to_granted_at?

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

        private

        def elections_with_census_permissions
          Decidim::Vocdoni::Election.where(census_type: "census_permissions")
        end
      end
    end
  end
end
