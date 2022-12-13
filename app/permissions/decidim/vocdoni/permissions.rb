# frozen_string_literal: true

module Decidim
  module Vocdoni
    class Permissions < Decidim::DefaultPermissions
      def permissions
        if permission_action.scope == :public && permission_action.subject == :election
          case permission_action.action
          when :preview
            toggle_allow(can_preview?)
          when :view
            toggle_allow(can_view?)
          end
        end

        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Vocdoni::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        permission_action
      end

      private

      def can_view?
        election.published? || can_preview?
      end

      def can_preview?
        user&.admin?
      end

      def election
        @election ||= context[:election]
      end
    end
  end
end
