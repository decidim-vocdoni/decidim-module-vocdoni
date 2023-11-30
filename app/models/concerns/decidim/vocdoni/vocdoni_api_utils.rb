# frozen_string_literal: true

module Decidim
  module Vocdoni
    module VocdoniApiUtils
      include TranslatableAttributes
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
          I18n.with_locale(locale) do
            values[locale] = translated_attribute(translations, organization)
            values["default"] = values[locale] if organization.default_locale.to_s == locale
          end
        end
        values
      end
    end
  end
end
