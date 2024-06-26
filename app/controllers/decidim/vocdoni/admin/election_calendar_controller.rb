# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class ElectionCalendarController < Admin::ApplicationController
        helper_method :election

        def edit
          enforce_permission_to(:update, :election_calendar, election:)

          @election_calendar_form = ElectionCalendarForm.from_model(election)
        end

        def update
          enforce_permission_to(:update, :election_calendar, election:)

          @election_calendar_form = ElectionCalendarForm.from_params(params)
          @election_calendar_form.secret_until_the_end = params[:result_type] == "after_voting"

          UpdateElectionCalendar.call(@election_calendar_form, election) do
            on(:ok) do
              redirect_to publish_page_election_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("elections.create.invalid", scope: "decidim.vocdoni.admin")
              render action: "edit"
            end
          end
        end

        private

        def election
          @election ||= Decidim::Vocdoni::Election.find(params[:election_id])
        end
      end
    end
  end
end
