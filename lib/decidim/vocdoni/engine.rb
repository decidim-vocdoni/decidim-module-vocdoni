# frozen_string_literal: true

require "rails"
require "decidim/core"
require "active_support/all"

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

      initializer "decidim.vocdoni.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Vocdoni::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Vocdoni::Engine.root}/app/views") # for partials
      end

      initializer "decidim_vocdoni.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim.vocdoni.register_icons" do
        Decidim.icons.register(name: "book-2-line", icon: "book-2-line", category: "system", description: "", engine: :vocdoni)
        Decidim.icons.register(name: "checkbox-multiple-line", icon: "checkbox-multiple-line", category: "system", description: "", engine: :vocdoni)
        Decidim.icons.register(name: "bar-chart-box-line", icon: "bar-chart-box-line", category: "system", description: "", engine: :vocdoni)
      end
    end
  end
end
