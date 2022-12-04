# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This is the engine that runs on the public interface of `Vocdoni`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Vocdoni::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :vocdoni do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "vocdoni#index"
      end

      def load_seed
        nil
      end
    end
  end
end
