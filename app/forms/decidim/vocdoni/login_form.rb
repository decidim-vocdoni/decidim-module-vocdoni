# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Census
      # This class holds the data to login with census data
      class LoginForm < Decidim::Form
        attribute :access_code, String
        validates :access_code, presence: true
      end
    end
  end
end
