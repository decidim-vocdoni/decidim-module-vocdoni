# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class SdkRunnerJob < ApplicationJob
        def perform(organization_id, command)
          @organization_id = organization_id

          output = Sdk.new(organization).send(command)
          Rails.logger.info "NodeRunnerJob[#{command}]: #{output}"
        end

        private

        def organization
          @organization ||= Decidim::Organization.find(@organization_id)
        end
      end
    end
  end
end
