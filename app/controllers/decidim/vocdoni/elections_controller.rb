# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Exposes the elections resources so users can participate on them
    class ElectionsController < Decidim::Vocdoni::ApplicationController
      helper_method :elections, :election, :single?

      def index
        redirect_to election_path(single, single: true) if single?
      end

      def show
        enforce_permission_to :view, :election, election: election
      end

      private

      def elections
        @elections ||= Election.where(component: current_component).published
      end

      def election
        # The single election is searched from non-published records on purpose
        # to allow previewing for admins.
        @election ||= Election.where(component: current_component).find(params[:id])
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
