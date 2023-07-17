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

        def update
          enforce_permission_to :update, :steps, election: election
          @form = form(current_step_form_class).from_params(params, election: election)

          current_step_command_class.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("steps.#{current_step}.success", scope: "decidim.vocdoni.admin")
              return redirect_to election_steps_path(election)
            end
            on(:invalid) do |message|
              flash.now[:alert] = message || I18n.t("steps.#{current_step}.invalid", scope: "decidim.vocdoni.admin")
            end
          end
          render :index
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
            "create_election" => SetupForm,
            "paused" => ElectionStatusForm,
            "vote" => ElectionStatusForm,
            "vote_ended" => ResultsForm
          }[current_step]
        end

        def current_step_command_class
          @current_step_command_class ||= {
            "create_election" => SetupElection,
            "paused" => UpdateElectionStatus,
            "vote" => UpdateElectionStatus,
            "vote_ended" => SaveResults
          }[current_step]
        end

        def current_step
          if election.manual_start? && election.status == "paused"
            @current_step = "created"
          else
            @current_step ||= election.status || "create_election"
          end
        end

        def elections
          @elections ||= Decidim::Vocdoni::Election.where(component: current_component)
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
