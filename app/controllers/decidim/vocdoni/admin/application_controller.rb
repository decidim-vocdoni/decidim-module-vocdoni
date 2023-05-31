# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper Decidim::Vocdoni::Admin::StepsWizardHelper

        def permission_class_chain
          [::Decidim::Vocdoni::Admin::Permissions] + super
        end

        def user_not_authorized_path
          decidim.root_path
        end

        def user_has_no_permission_path
          decidim.root_path
        end
      end
    end
  end
end
