# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Exposes the elections resources so users can participate on them
    class ElectionsController < Decidim::Vocdoni::ApplicationController
      include Decidim::Vocdoni::HasVoteFlow
      include Decidim::Vocdoni::Orderable
      include FilterResource
      include Paginable

      helper_method :elections, :election, :single?, :paginated_elections, :scheduled_elections

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

      def paginated_elections
        @paginated_elections ||= reorder(search.result.published)
        @paginated_elections = paginate(@paginated_elections)
      end

      def scheduled_elections
        @scheduled_elections ||= search_with(filter_params.merge(with_any_date: %w(active upcoming))).result
      end

      def search_collection
        Election.where(component: current_component).published
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_any_date: default_filter_date_params
        }
      end

      def default_filter_date_params
        if elections.active.any?
          %w(active)
        elsif elections.upcoming.any?
          %w(upcoming)
        else
          %w()
        end
      end
    end
  end
end
