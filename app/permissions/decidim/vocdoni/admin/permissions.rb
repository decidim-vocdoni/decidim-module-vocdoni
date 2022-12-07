# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user&.admin?

          case permission_action.subject
          when :question, :answer
            case permission_action.action
            when :create, :update, :delete
              allow!
            end
          when :election
            case permission_action.action
            when :create, :read, :update, :publish, :unpublish, :delete
              allow!
            end
          end

          permission_action
        end
      end
    end
  end
end
