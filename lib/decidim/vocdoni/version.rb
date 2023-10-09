# frozen_string_literal: true

module Decidim
  # This holds the module version and its compatiblity with Decidim
  module Vocdoni
    COMPAT_DECIDIM_VERSION = [">= 0.27.0", "< 0.28"].freeze

    def self.version
      "0.27.1"
    end
  end
end
