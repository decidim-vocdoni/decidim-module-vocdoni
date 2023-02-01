# frozen_string_literal: true

module Decidim
  module Vocdoni
      # This class presents the data to login with census data
      # It'll not be checked server side on Decidim, but it'll be sent to Vocdoni
      # with the SDK
    class LoginForm < Decidim::Form
      attribute :email, String
      attribute :day, Integer
      attribute :month, Integer
      attribute :year, Integer
    end
  end
end
