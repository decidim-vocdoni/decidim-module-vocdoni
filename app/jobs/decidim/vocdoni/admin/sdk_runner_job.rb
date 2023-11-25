# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class SdkRunnerJob < ApplicationJob
        def perform(organization_id:, command:, election_id: nil)
          @organization_id = organization_id
          @election_id = election_id

          output = Sdk.new(organization, election).send(command)
          Rails.logger.info "NodeRunnerJob[#{command}]: #{output}"
        end

        private

        def organization
          @organization ||= Decidim::Organization.find(@organization_id)
        end

        def election
          @election ||= Decidim::Election.find_by(id: @election_id)
        end
      end
    end
  end
end
