# frozen_string_literal: true

require "spec_helper"
require "open3"

module Decidim
  describe Vocdoni do
    describe "default configuration from ENV" do
      let(:test_app) { Rails.root }
      let(:env) do
        {
          "VOCDONI_MINUTES_BEFORE_START" => minutes,
          "VOCDONI_RESELLER_NAME" => reseller_name,
          "VOCDONI_RESELLER_EMAIL" => reseller_email,
          "DECIDIM_VOCDONI_VOTES_OVERWRITE_MAX" => votes_overwrite_max,
          "VOCDONI_API_ENDPOINT_ENV" => vocdoni_env,
          "VOCDONI_MANUAL_START_DELAY" => start_delay
        }
      end
      let(:vocdoni_env) { "STG" }
      let(:minutes) { "11" }
      let(:votes_overwrite_max) { "8" }
      let(:start_delay) { "33" }
      let(:reseller_name) { "Test reseller" }
      let(:reseller_email) { "test_reseller@example.org" }
      let(:config) { JSON.parse cmd_capture("bin/rails runner 'puts Decidim::Vocdoni.config.to_json'", env: env) }
      let(:endpoint_env) { cmd_capture("bin/rails runner 'puts Decidim::Vocdoni.api_endpoint_env'", env: env) }

      def cmd_capture(cmd, env: {})
        Dir.chdir(test_app) do
          Open3.capture2(env.merge("RUBYOPT" => "-W0"), cmd)[0]
        end
      end

      it "has the correct configuration" do
        expect(config).to eq({
                               "minimum_minutes_before_start" => 11,
                               "vocdoni_reseller_email" => "test_reseller@example.org",
                               "vocdoni_reseller_name" => "Test reseller",
                               "votes_overwrite_max" => 8,
                               "api_endpoint_env" => "STG",
                               "manual_start_time_delay" => 33,
                               "interruptible_elections" => true
                             })
      end

      it "has the correct endpoint env" do
        expect(endpoint_env.strip).to eq("STG")
      end

      it "has the correct endpoint url" do
        expect(Decidim::Vocdoni::API_ENDPOINTS["stg"]).to eq("https://api-stg.vocdoni.net/v2")
        expect(Decidim::Vocdoni::API_ENDPOINTS["dev"]).to eq("https://api-dev.vocdoni.net/v2")
        expect(Decidim::Vocdoni::API_ENDPOINTS["prod"]).to eq("https://api.vocdoni.io/v2")
      end

      context "when enpoint is wrong" do
        let(:vocdoni_env) { "WRONG" }

        it "defaults to dev" do
          expect(endpoint_env.strip).to eq("WRONG")
        end
      end
    end
  end
end
