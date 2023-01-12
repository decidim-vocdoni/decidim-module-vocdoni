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
      #    WalletPresenter.new(action_log, view_helpers).present
      class WalletPresenter < Decidim::Log::BasePresenter
        private

        def i18n_labels_scope
          "activemodel.attributes.wallet"
        end

        def action_string
          case action
          when "create"
            "decidim.vocdoni.admin_log.wallet.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
