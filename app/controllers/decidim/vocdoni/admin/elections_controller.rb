# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows the create or update an election.
      class ElectionsController < Admin::ApplicationController
        helper_method :elections, :election

        def index
          # flash.now[:alert] ||= I18n.t("elections.index.no_bulletin_board", scope: "decidim.vocdoni.admin").html_safe unless Decidim::Elections.bulletin_board.configured?
        end

        def new
          enforce_permission_to :create, :election
          @form = form(ElectionForm).instance
        end

        def create
          enforce_permission_to :create, :election
          @form = form(ElectionForm).from_params(params, current_component: current_component)

          CreateElection.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.create.success", scope: "decidim.vocdoni.admin")
              redirect_to election_questions_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.create.invalid", scope: "decidim.vocdoni.admin")
              render action: "new"
            end
          end
        end

        # returns useful information about the election in JSON format
        # this makes a call to the Vocdoni API so best to use it asynchronically
        def show
          enforce_permission_to :read, :election, election: election

          info = Sdk.new(current_organization).info
          info.merge!(vocdoniElectionId: election.vocdoni_election_id)
          render json: info
        end

        def edit
          enforce_permission_to :update, :election, election: election
          @form = form(ElectionForm).from_model(election)
        end

        def update
          enforce_permission_to :update, :election, election: election
          @form = form(ElectionForm).from_params(params, current_component: current_component)

          UpdateElection.call(@form, election) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.update.success", scope: "decidim.vocdoni.admin")
              redirect_to election_questions_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.update.invalid", scope: "decidim.vocdoni.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :election, election: election

          DestroyElection.call(election, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("elections.destroy.success", scope: "decidim.vocdoni.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("elections.destroy.invalid", scope: "decidim.vocdoni.admin")
            end
          end

          redirect_to elections_path
        end

        def publish_page
          enforce_permission_to :publish, :election, election: election
        end

        def publish
          enforce_permission_to :publish, :election, election: election

          PublishElection.call(election, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("admin.elections.publish.success", scope: "decidim.vocdoni")
              redirect_to publish_page_election_path(election)
            end
          end
        end

        def unpublish
          enforce_permission_to :unpublish, :election, election: election

          UnpublishElection.call(election, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("admin.elections.unpublish.success", scope: "decidim.vocdoni")
              redirect_to publish_page_election_path(election)
            end
          end
        end

        def manual_start
          enforce_permission_to :manual_start, :steps, election: election

          ManualStartElection.call(election) do
            on(:ok) do
              flash[:notice] = I18n.t("admin.elections.manual_start.success", scope: "decidim.vocdoni")
              redirect_to election_steps_path(election)
            end
          end
        end

        def credits
          enforce_permission_to :read, :election, election: election

          SdkRunnerJob.perform_later(organization_id: current_organization.id, command: :collectFaucetTokens)
          flash[:notice] = I18n.t("admin.elections.credits.success", scope: "decidim.vocdoni")

          redirect_to election_steps_path(election)
        end

        private

        def elections
          @elections ||= Decidim::Vocdoni::Election.where(component: current_component).order(start_time: :desc)
        end

        def election
          @election ||= elections.find_by(id: params[:id])
        end
      end
    end
  end
end
