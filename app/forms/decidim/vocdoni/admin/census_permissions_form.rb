# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusPermissionsForm < Decidim::Form
        mimic :census_permissions

        attribute :census_permissions, Array[String]

        def data
          verification_types = census_permissions
          Decidim::Authorization.where(name: verification_types).map(&:user).uniq
        end
      end
    end
  end
end
