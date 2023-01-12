# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows to manage the steps of an election.
      class StepsController < Admin::ApplicationController
        helper Decidim::ApplicationHelper
        helper StepsHelper
        helper_method :elections, :election, :current_step

        before_action :ensure_wallet_created

        def index
          enforce_permission_to :read, :steps, election: election

          if current_step_form_class
            @form = form(current_step_form_class).instance(election: election)
            @form.valid?
          end
        end

        private

        def ensure_wallet_created
          return if current_vocdoni_wallet

          session[:redirect_back] = election.id
          flash[:warning] = I18n.t("wallet.create.pending", scope: "decidim.vocdoni.admin")
          redirect_to new_wallet_path
        end

        def current_step_form_class
          @current_step_form_class ||= {
            "create_election" => SetupForm
          }[current_step]
        end

        def current_step
          @current_step ||= election.status || "create_election"
        end

        def elections
          @elections ||= Election.where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:election_id])
        end

        def current_vocdoni_wallet
          @current_vocdoni_wallet ||= Decidim::Vocdoni::Wallet.find_by(decidim_organization_id: current_organization.id)
        end
      end
    end
  end
end
