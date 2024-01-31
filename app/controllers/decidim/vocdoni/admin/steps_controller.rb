# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows to manage the steps of an election.
      class StepsController < Admin::ApplicationController
        helper Decidim::ApplicationHelper
        helper StepsHelper
        helper_method :elections, :election, :current_step, :census_needs_update?,
                      :new_users_with_authorizations_and_voters, :users_awaiting_census

        before_action :ensure_wallet_created

        def index
          enforce_permission_to :read, :steps, election: election
          if current_step_form_class
            @form = form(current_step_form_class).from_params({ status: election.status }, election: election)
            @form.valid?
          end
        end

        def show
          enforce_permission_to :read, :steps, election: election

          respond_to do |format|
            format.html { render partial: "decidim/vocdoni/admin/steps/results_stats" }
            format.json do
              info = Sdk.new(election.organization, election).electionMetadata[params[:id]]
              render json: { election: info }, status: info ? :ok : :unprocessable_entity
            end
          end
        end

        def update
          enforce_permission_to :update, :steps, election: election
          @form = form(current_step_form_class).from_params(params, election: election)

          current_step_command_class.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("steps.#{election.status}.success", scope: "decidim.vocdoni.admin")
              return redirect_to election_steps_path(election)
            end
            on(:invalid) do |message|
              flash.now[:alert] = message || I18n.t("steps.#{current_step}.invalid", scope: "decidim.vocdoni.admin")
            end
            on(:status) do |status|
              flash[:alert] = I18n.t("steps.invalid_status", scope: "decidim.vocdoni.admin", status: status)
              return redirect_to election_steps_path(election)
            end
          end
          render :index
        end

        def update_census
          # TODO: check elction internal_census, permissions...
          # TODO flash message "updating census"

          non_voter_ids = new_users_with_authorizations_and_voters[:non_voters].pluck(:id)

          UpdateElectionCensusJob.perform_later(election, non_voter_ids)
          redirect_to election_steps_path(election)
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
            "created" => ElectionStatusForm, # This allows for resending data to vocdoni if there's been a problem
            "paused" => ElectionStatusForm,
            "vote" => ElectionStatusForm,
            "vote_ended" => ResultsForm
          }[current_step]
        end

        def current_step_command_class
          @current_step_command_class ||= {
            "create_election" => SetupElection,
            "created" => UpdateElectionStatus,
            "paused" => UpdateElectionStatus,
            "vote" => UpdateElectionStatus,
            "vote_ended" => SaveResults
          }[current_step]
        end

        def current_step
          @current_step ||= election.status || "create_election"
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

        def census_needs_update?
          return false unless election.internal_census?

          true if new_users_with_authorizations_and_voters[:non_voters].count.positive?
        end

        def users_awaiting_census
          new_users_with_authorizations_and_voters[:non_voters].count
        end

        def new_users_with_authorizations
          verification_types = election.verification_types

          users = current_organization.users.not_deleted.confirmed
          if verification_types.present?
            verified_users = Decidim::Authorization.select(:decidim_user_id)
                                                   .where(decidim_user_id: users.select(:id))
                                                   .where.not(granted_at: nil)
                                                   .where(name: verification_types)
                                                   .group(:decidim_user_id)
                                                   .having("COUNT(distinct name) = ?", verification_types.count)
            users = users.where(id: verified_users)
          end

          users
        end

        def new_users_with_authorizations_and_voters
          users = new_users_with_authorizations
          voters = Decidim::Vocdoni::Voter.where(email: users.select(:email), in_vocdoni_census: true)
                                          .where.not(wallet_address: [nil, ""])
          voter_emails = voters.pluck(:email)
          non_voters = users.where.not(email: voter_emails)
          {non_voters: non_voters}
        end
      end
    end
  end
end
