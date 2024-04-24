# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This is the engine that runs on the public interface of `Vocdoni`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Vocdoni::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :wallets, only: [:new, :create]
        resources :elections do
          member do
            get :publish_page, path: "publish_election"
            put :publish
            put :unpublish
            post :credits
          end
          resources :steps, only: [:index, :show, :update] do
            collection do
              put :update_census
              get :census_data, defaults: { format: :json }
            end
          end
          resources :questions do
            resources :answers
          end
          resources :census, only: [:index, :create] do
            delete :destroy_all, on: :collection, as: :destroy_all
          end
          resource :calendar, controller: "election_calendar", only: [:edit, :update]
        end
        root to: "elections#index"
      end

      initializer "decidim_admin.register_icons" do
        Decidim.icons.register(name: "bank-card-line", icon: "bank-card-line", category: "system", description: "", engine: :vocdoni)
        Decidim.icons.register(name: "pause-circle-line", icon: "pause-circle-line", category: "system", description: "", engine: :vocdoni)
        Decidim.icons.register(name: "play-circle-line", icon: "play-circle-line", category: "system", description: "", engine: :vocdoni)
        Decidim.icons.register(name: "stop-circle-line", icon: "stop-circle-line", category: "system", description: "", engine: :vocdoni)
      end

      def load_seed
        nil
      end
    end
  end
end
