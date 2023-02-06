# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusController < Admin::ApplicationController
        helper_method :elections, :election, :census_path

        def index
          enforce_permission_to :index, :census, election: election

          @form = current_step_form_instance
        end

        def create
          enforce_permission_to :create, :census, election: election
          @form = form(current_step_form_class).from_params(params)

          current_step_command_class.call(@form, election) do
            on(:ok) do
              flash[:notice] = if @form.respond_to?(:data)
                                 t(".success.import", count: @form.data.values.count, errors: @form.data.errors.count)
                               else
                                 t(".success.generate")
                               end
              redirect_to election_census_path(election)
            end

            on(:invalid) do
              flash[:alert] = t(".error")
              render :index
            end
          end
        end

        def destroy_all
          enforce_permission_to :destroy, :census, election: election
          Voter.clear(election)

          redirect_to election_census_path(election), notice: t(".success")
        end

        private

        def current_step_form_instance
          @current_step_form_instance ||= case current_step
                                          when "pending_upload"
                                            form(current_step_form_class).instance
                                          when "pending_generation"
                                            form(current_step_form_class).from_model(
                                              OpenStruct.new(credentials: Voter.where(election: election))
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
          @elections ||= Election.where(component: current_component)
        end

        def election
          @election ||= elections.find_by(id: params[:election_id])
        end
      end
    end
  end
end
