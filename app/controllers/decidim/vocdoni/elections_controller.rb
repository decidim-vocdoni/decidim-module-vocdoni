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

      def current_vocdoni_wallet
        @current_vocdoni_wallet ||= Decidim::Vocdoni::Wallet.find_by(decidim_organization_id: current_organization.id)
      end

      def api_endpoint_env
        @api_endpoint_env ||= Decidim::Vocdoni.api_endpoint_env
      end

      def vocdoni_client
        @vocdoni_client ||= Decidim::Vocdoni::VocdoniClient.new(wallet: current_vocdoni_wallet.private_key, api_endpoint_env: api_endpoint_env)
      end

      def vocdoni_election_id
        @vocdoni_election_id ||= election.vocdoni_election_id
      end

      def election_data
        @election_data ||= vocdoni_client.fetch_election(vocdoni_election_id)
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
