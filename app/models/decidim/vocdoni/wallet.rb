# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Vocdoni wallet.
    class Wallet < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      validates :private_key, presence: true, uniqueness: true

      def self.log_presenter_class_for(_log)
        Decidim::Vocdoni::AdminLog::WalletPresenter
      end
    end
  end
end
