# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusPermissionsForm < Decidim::Form
        attribute :verification_types, Array[String]

        def data
          verification_types.select! { |type| valid_authorization_types.include?(type) }

          return [] if verification_types.blank?

          users = context.current_organization.users.not_deleted.confirmed
          verified_users = Decidim::Authorization
                           .select(:decidim_user_id)
                           .where(decidim_user_id: users.select(:id))
                           .where.not(granted_at: nil)
                           .where(name: verification_types)
                           .group(:decidim_user_id)
                           .having("COUNT(distinct name) = ?", verification_types.count)

          users.where(id: verified_users)
        end

        private

        def valid_authorization_types
          context.current_organization.available_authorizations
        end
      end
    end
  end
end
