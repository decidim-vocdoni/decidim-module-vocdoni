# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Vocdoni
    # This is the engine that runs on the public interface of vocdoni.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Vocdoni

      routes do
        # Add engine routes here
        # resources :vocdoni
        # root to: "vocdoni#index"
      end

      initializer "decidim_vocdoni.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
