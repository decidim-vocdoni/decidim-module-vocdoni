# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Vocdoni
    # This is the engine that runs on the public interface of vocdoni.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Vocdoni

      routes do
        resources :elections, only: [:index, :show] do
          resources :votes, only: [:new, :create, :update, :show] do
            match "new", action: :new, via: :post, as: :login, on: :collection
            post "votes_left", on: :collection
            get "check_verification", on: :collection, to: "votes#check_verification"
          end
        end

        root to: "elections#index"
      end

      initializer "decidim.vocdoni.overrides" do
        config.to_prepare do
          Decidim::Authorization.include(Decidim::Vocdoni::AuthorizationOverride)
        end
      end

      initializer "decidim.vocdoni.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Vocdoni::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Vocdoni::Engine.root}/app/views") # for partials
      end

      initializer "decidim_vocdoni.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
