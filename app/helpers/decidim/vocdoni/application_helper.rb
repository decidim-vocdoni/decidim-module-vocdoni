# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Custom helpers, scoped to the vocdoni engine.
    #
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper

      def date_filter_values
        TreeNode.new(
          TreePoint.new("", t("elections.elections.filters.all", scope: "decidim.vocdoni")),
          [
            TreePoint.new("active", t("elections.elections.filters.active", scope: "decidim.vocdoni")),
            TreePoint.new("upcoming", t("elections.elections.filters.upcoming", scope: "decidim.vocdoni")),
            TreePoint.new("finished", t("elections.elections.filters.finished", scope: "decidim.vocdoni"))
          ]
        )
      end

      def filter_sections
        @filter_sections ||= [{ method: :with_any_date,
                                collection: date_filter_values,
                                label_scope: "decidim.vocdoni.elections.elections.filters",
                                id: "date" }]
      end

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.vocdoni.name")
      end
    end
  end
end
