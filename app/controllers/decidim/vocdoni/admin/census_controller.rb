# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CensusController < Admin::ApplicationController
        helper_method :elections, :election, :census_path

        def index
          enforce_permission_to :index, :census, election: election

          @form = form(CensusDataForm).instance
          @status = CsvCensus::Status.new(election)
        end

        def create
          enforce_permission_to :create, :census, election: election
          @form = form(CensusDataForm).from_params(params)
          @status = CsvCensus::Status.new(election)

          CreateCensusData.call(@form, election) do
            on(:ok) do
              flash[:notice] = t(".success", count: @form.data.values.count, errors: @form.data.errors.count)
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
          CsvDatum.clear(election)

          redirect_to election_census_path(election), notice: t(".success")
        end

        private

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
