# frozen_string_literal: true

module Decidim
  module Vocdoni
    module ContentSecurityPolicy
      extend ActiveSupport::Concern

      included do
        after_action :append_vocdoni_csp_directives_for_env
      end

      def append_vocdoni_csp_directives_for_env
        vocdoni_api_url = Decidim::Vocdoni.api_endpoint_url
        vocdoni_api_domain = extract_domain(vocdoni_api_url)

        content_security_policy.append_csp_directive("connect-src", vocdoni_api_domain)
      end

      private

      def extract_domain(url)
        uri = URI.parse(url)
        "#{uri.scheme}://#{uri.host}"
      end
    end
  end
end
