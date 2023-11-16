# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusPermissionsForm < Decidim::Form
        mimic :census_permissions

        attribute :census_permissions, Array[String]

        def data
          verification_types = census_permissions

          verified_users_ids = Decidim::Authorization
                               .where(name: verification_types)
                               .group(:decidim_user_id)
                               .having("COUNT(distinct name) = ?", verification_types.count)
                               .pluck(:decidim_user_id)

          Decidim::User.where(id: verified_users_ids).uniq
        end
      end
    end
  end
end
