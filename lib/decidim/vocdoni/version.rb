# frozen_string_literal: true

module Decidim
  # This holds the decidim-meetings version.
  module Vocdoni
    DECIDIM_VERSION = "0.28.1"
    DECIDIM_COMPAT_VERSION = [">= 0.28.0", "< 0.29"].freeze

    def self.version
      "2.0"
    end
  end
end
