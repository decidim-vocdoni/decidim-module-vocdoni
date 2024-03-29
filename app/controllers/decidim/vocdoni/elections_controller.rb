# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Exposes the elections resources so users can participate on them
    class ElectionsController < Decidim::Vocdoni::ApplicationController
      include Decidim::Vocdoni::HasVoteFlow

      helper_method :elections, :election, :single?

      def index
        redirect_to election_path(single, single: true) if single?
      end

      def show
        enforce_permission_to :view, :election, election: election

        @election_data = election_metadata

        respond_to do |format|
          format.html
          format.json do
            render json: { election_data: @election_data }
          end
        end
      end

      private

      def elections
        @elections ||= Decidim::Vocdoni::Election.where(component: current_component).published
      end

      def election
        # The single election is searched from non-published records on purpose
        # to allow previewing for admins.
        @election ||= Decidim::Vocdoni::Election.where(component: current_component).find(params[:id])
      end

      def vocdoni_client
        @vocdoni_client ||= Api.new(vocdoni_election_id: election.vocdoni_election_id)
      end

      def election_metadata
        return nil unless !election.election_type["secret_until_the_end"] && election.ongoing?

        @election_metadata ||= vocdoni_client.fetch_election
      end

      # Public: Checks if the component has only one election resource.
      #
      # Returns Boolean.
      def single?
        elections.one?
      end

      def single
        elections.first if single?
      end
    end
  end
end
