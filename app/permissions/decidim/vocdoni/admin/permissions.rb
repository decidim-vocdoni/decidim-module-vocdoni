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
              allow_question_step
            end
          when :election
            case permission_action.action
            when :create, :read
              allow!
            when :delete, :update
              allow_if_not_blocked
            when :publish, :unpublish
              allow_publish_step
            end
          when :election_calendar
            case permission_action.action
            when :update, :edit
              allow_calendar_step
            end
          when :census
            case permission_action.action
            when :index, :create, :destroy
              allow_census_step
            end
          when :steps
            case permission_action.action
            when :read, :update
              allow!
            end
          when :wallet
            case permission_action.action
            when :create
              allow! if current_vocdoni_wallet.nil?
            end
          end

          permission_action
        end

        private

        def election
          @election ||= context.fetch(:election, nil)
        end

        def current_vocdoni_wallet
          @current_vocdoni_wallet ||= Decidim::Vocdoni::Wallet.find_by(decidim_organization_id: user.organization.id)
        end

        def allow_if_not_blocked
          toggle_allow(election && !election.blocked?)
        end

        def allow_question_step
          return if election.blank?

          toggle_allow(election.ready_for_questions_form?)
        end

        def allow_calendar_step
          toggle_allow(election.ready_for_calendar_form?)
        end

        def allow_publish_step
          return if election.blank?

          toggle_allow(election.ready_for_publish_form?)
        end

        def allow_census_step
          return if election.blank?

          toggle_allow(election.ready_for_census_form?)
        end
      end
    end
  end
end
