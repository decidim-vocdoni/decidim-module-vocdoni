# frozen_string_literal: true

module Decidim
  module Vocdoni
    module AdminLog
      # This class holds the logic to present a `Decidim::Vocdoni`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ElectionPresenter.new(action_log, view_helpers).present
      class ElectionPresenter < Decidim::Log::BasePresenter
        private

        def i18n_labels_scope
          "activemodel.attributes.election"
        end

        def action_string
          case action
          when "publish", "unpublish", "create", "delete", "update", "setup", "start_vote", "end_vote", "start_tally", "publish_results"
            "decidim.vocdoni.admin_log.election.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
