# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class CreateVocdoniElectionJob < ApplicationJob
        def perform(election_id)
          @election_id = election_id

          Rails.logger.info "CreateVocdoniElectionJob: Creating election #{election_id} at Vocdoni env #{Decidim::Vocdoni.api_endpoint_env}"

          # json format
          data = election.to_json
          # add census through the sdk
          data["census"] = add_census
          # add questions through the sdk
          data["questions"] = add_questions
        end

        private

        def add_census
          # todo
        end

        def add_questions
          # todo
        end

        def sdk
          @sdk ||= Sdk.new(organization, election)
        end

        def organization
          @organization ||= election&.organization
        end

        def election
          @election ||= Decidim::Vocdoni::Election.find_by(id: @election_id)
        end
      end
    end
  end
end
