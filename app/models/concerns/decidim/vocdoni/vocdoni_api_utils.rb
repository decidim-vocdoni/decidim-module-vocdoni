# frozen_string_literal: true

module Decidim
  module Vocdoni
    module VocdoniApiUtils
      include TranslationHelpers
      # Transform the locales to the required format with a default locale
      #
      # receives an array with the following format:
      #    [{"text": "Nom", "locale": "ca"}, {"text": "Name","locale": "en"}]
      #
      # @returns {object} An object with the following format:
      #    {ca: "Nom", default: "Name"}
      def transform_locales(translations)
        values = {}
        organization.available_locales.each do |locale|
          locale = locale.to_s
          values[locale] = translated(translations, locale: locale).to_s
          values["default"] = values[locale] if organization.default_locale.to_s == locale
        end
        values
      end
    end
  end
end
