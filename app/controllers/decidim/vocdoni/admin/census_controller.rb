# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusController < Admin::ApplicationController
        helper_method :elections, :election, :census_path, :status

        def index
          enforce_permission_to :index, :census, election: election

          @form = current_step_form_instance
          @census_permissions_form = form(CensusPermissionsForm).instance
        end

        def create
          enforce_permission_to :create, :census, election: election

          if params[:census_permissions]
            handle_census_permissions
          else
            handle_census_csv
          end
        end

        def destroy_all
          enforce_permission_to :destroy, :census, election: election
          Voter.clear(election)

          redirect_to election_census_path(election), notice: t(".success")
        end

        private

        class CredentialCensusData
          attr_accessor :credentials

          def initialize(credentials:)
            @credentials = credentials
          end
        end

        def current_step_form_instance
          @current_step_form_instance ||= case current_step
                                          when "pending_upload"
                                            form(current_step_form_class).instance
                                          when "pending_generation"
                                            form(current_step_form_class).from_model(
                                              CredentialCensusData.new(credentials: Voter.where(election: election))
                                            )
                                          when "ready"
                                            nil
                                          end
        end

        def current_step_form_class
          @current_step_form_class ||= {
            "pending_upload" => CensusDataForm,
            "pending_generation" => CensusCredentialsForm
          }[current_step]
        end

        def current_step_command_class
          @current_step_command_class ||= {
            "pending_upload" => CreateCensusData,
            "pending_generation" => CreateCensusCredentials
          }[current_step]
        end

        def status
          @status = CsvCensus::Status.new(election)
        end

        def current_step
          @current_step ||= status.name
        end

        def elections
          @elections ||= Decidim::Vocdoni::Election.where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:election_id])
        end

        def handle_census_permissions
          @form = form(CensusPermissionsForm).from_params(params[:census_permissions])

          process_form(@form, CreateCensusWithPermissions, success_message_for(@form), :index)
        end

        def handle_census_csv
          @form = form(current_step_form_class).from_params(params)

          process_form(@form, current_step_command_class, success_message_for(@form, count_method: :values, error_method: :errors), :index)
        end

        def process_form(form, command_class, success_message, failure_template)
          command_class.call(form, election) do
            on(:ok) { set_flash_and_redirect(:notice, success_message) }
            on(:invalid) { set_flash_and_render(:alert, t(".error"), failure_template) }
          end
        end

        def success_message_for(form, count_method: :count, error_method: nil)
          if form.respond_to?(:data)
            t(".success.import",
              count: form.data.send(count_method),
              errors: error_method ? form.data.send(error_method).count : 0)
          else
            t(".success.generate")
          end
        end

        def set_flash_and_redirect(type, message)
          flash[type] = message
          redirect_to election_census_path(election)
        end

        def set_flash_and_render(type, message, template)
          flash[type] = message
          render template
        end
      end
    end
  end
end
