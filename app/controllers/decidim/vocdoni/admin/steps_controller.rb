# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows to manage the steps of an election.
      class StepsController < Admin::ApplicationController
        helper Decidim::ApplicationHelper
        helper StepsHelper
        helper_method :elections, :election, :current_step, :users_awaiting_census

        before_action :ensure_wallet_created

        def index
          enforce_permission_to(:read, :steps, election:)
          if current_step_form_class
            @form = form(current_step_form_class).from_params({ status: election.status }, election:)
            @form.valid?
          end
        end

        def show
          enforce_permission_to(:read, :steps, election:)

          respond_to do |format|
            format.html { render partial: "decidim/vocdoni/admin/steps/results_stats" }
            format.json do
              info = Sdk.new(election.organization, election).electionMetadata[params[:id]]
              render json: { election: info }, status: info ? :ok : :unprocessable_entity
            end
          end
        end

        def update
          enforce_permission_to(:update, :steps, election:)
          @form = form(current_step_form_class).from_params(params, election:)

          current_step_command_class.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("steps.#{election.status}.success", scope: "decidim.vocdoni.admin")
              return redirect_to election_steps_path(election)
            end
            on(:invalid) do |message|
              flash.now[:alert] = message || I18n.t("steps.#{current_step}.invalid", scope: "decidim.vocdoni.admin")
            end
            on(:status) do |status|
              flash[:alert] = I18n.t("steps.invalid_status", scope: "decidim.vocdoni.admin", status:)
              return redirect_to election_steps_path(election)
            end
          end
          render :index
        end

        def update_census
          enforce_permission_to(:update, :steps, election:)

          return unless election.internal_census?

          non_voter_ids = non_voters_users_with_authorizations(election).pluck(:id)
          UpdateElectionCensusJob.perform_later(election.id, non_voter_ids, current_user.id)

          redirect_to election_steps_path(election)
        end

        def census_data
          none_text = I18n.t("steps.census.none", scope: "decidim.vocdoni.admin")
          success_message = I18n.t("status.update_census_result_html", scope: "decidim.vocdoni.admin.census")

          info = {
            census_last_updated_at: election.census_last_updated_at&.strftime("%Y-%m-%d %H:%M:%S") || none_text,
            last_census_update_records_added: election.last_census_update_records_added || none_text,
            users_awaiting_census: I18n.t("users_awaiting_census", scope: "decidim.vocdoni.admin.steps.census", count: users_awaiting_census(election)).html_safe,
            update_message: success_message
          }

          render json: { info: }, status: info ? :ok : :unprocessable_entity
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
            "vote_ended" => ResultsForm,
            "results_published" => election.answers_have_results? ? nil : ResultsForm
          }[current_step]
        end

        def current_step_command_class
          @current_step_command_class ||= {
            "create_election" => SetupElection,
            "created" => UpdateElectionStatus,
            "paused" => UpdateElectionStatus,
            "vote" => UpdateElectionStatus,
            "vote_ended" => SaveResults,
            "results_published" => SaveResults
          }[current_step]
        end

        def current_step
          @current_step ||= election.status || "create_election"
        end

        def elections
          @elections ||= Decidim::Vocdoni::Election.includes(:component).where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:election_id])
        end

        def current_vocdoni_wallet
          @current_vocdoni_wallet ||= Decidim::Vocdoni::Wallet.find_by(decidim_organization_id: current_organization.id)
        end

        def users_awaiting_census(election)
          @users_awaiting_census ||= non_voters_users_with_authorizations(election).count
        end

        def new_users_with_authorizations(election)
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

        def non_voters_users_with_authorizations(election)
          users = new_users_with_authorizations(election)
          voters = Decidim::Vocdoni::Voter.where(decidim_vocdoni_election_id: election.id, in_vocdoni_census: true)
                                          .where.not(wallet_address: [nil, ""]).pluck(:email)

          users.where.not(email: voters)
        end
      end
    end
  end
end
