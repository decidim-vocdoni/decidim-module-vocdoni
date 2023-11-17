# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusPermissionsForm < Decidim::Form
        attribute :verification_types, Array[String]

        def data
          return [] if verification_types.blank?

          users = context.current_organization.users.not_deleted.confirmed

          verified_user_ids = Decidim::Authorization
                              .where(decidim_user_id: users.select(:id))
                              .where.not(granted_at: nil)
                              .where(name: verification_types)
                              .group(:decidim_user_id)
                              .having("COUNT(distinct name) = ?", verification_types.count)
                              .pluck(:decidim_user_id)

          users.where(id: verified_user_ids)
        end
      end
    end
  end
end
