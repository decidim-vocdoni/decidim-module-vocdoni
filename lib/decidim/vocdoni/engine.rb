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

      initializer "decidim_vocdoni.assets" do |app|
        app.config.assets.precompile += %w[decidim_vocdoni_manifest.js decidim_vocdoni_manifest.css]
      end
    end
  end
end
