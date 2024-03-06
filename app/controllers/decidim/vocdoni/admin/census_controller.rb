# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusController < Admin::ApplicationController
        helper_method :elections, :election, :status

        def index
          enforce_permission_to :index, :census, election: election

          return render json: status.to_json if request.xhr?

          @form = form(CensusDataForm).instance
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
          @form = form(CensusPermissionsForm).from_params(params[:census_permissions] || {})

          process_form(@form, CreateInternalCensus, success_message_for(@form), :index)
        end

        def handle_census_csv
          @form = form(CensusDataForm).from_params(params)

          process_form(@form, CreateCensusData, success_message_for(@form, error_method: :errors), :index)
        end

        def process_form(form, command_class, success_message, failure_template)
          command_class.call(form, election) do
            on(:ok) do
              flash[:notice] = success_message
              redirect_to election_census_path(election)
              CreateVoterWalletsJob.perform_later(election.id) if [CreateCensusData, CreateInternalCensus].include?(command_class)
            end
            on(:invalid) do
              flash[:alert] = t(".error")
              render failure_template
            end
          end
        end

        def success_message_for(form, error_method: nil)
          if form.respond_to?(:data)
            data = form.data
            count = if data.is_a?(ActiveRecord::Relation) || data.is_a?(ActiveRecord::AssociationRelation)
                      data.count
                    elsif data.respond_to?(:values)
                      valid_values = data.values.compact_blank
                      valid_values.size
                    else
                      0
                    end
            error_count = error_method && data.respond_to?(error_method) ? data.send(error_method).size : 0
            t(".success.import", count: count, errors: error_count)
          else
            t(".success.generate")
          end
        end

        def census_type
          if params[:census_permissions]
            "internal"
          else
            "external"
          end
        end
      end
    end
  end
end
