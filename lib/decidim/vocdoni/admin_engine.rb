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
            put :publish
            put :unpublish
          end
          resources :steps, only: [:index, :update]
          resources :questions do
            resources :answers
          end
        end
        root to: "elections#index"
      end

      def load_seed
        nil
      end
    end
  end
end
