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
          "VOCDONI_API_ENDPOINT_ENV" => vocdoni_env,
          "VOCDONI_MANUAL_START_TIME_SETTING_IN_SECONDS" => start_in_seconds
        }
      end
      let(:vocdoni_env) { "STG" }
      let(:minutes) { "11" }
      let(:start_in_seconds) { "33" }
      let(:config) { JSON.parse cmd_capture("bin/rails runner 'puts Decidim::Vocdoni.config.to_json'", env: env) }
      let(:endpoint_env) { cmd_capture("bin/rails runner 'puts Decidim::Vocdoni.api_endpoint_env'", env: env) }

      def cmd_capture(cmd, env: {})
        Dir.chdir(test_app) do
          Open3.capture2(env.merge("RUBYOPT" => "-W0"), cmd)[0]
        end
      end

      it "has the correct configuration" do
        expect(config).to eq({
                               "setup_minimum_minutes_before_start" => 11,
                               "api_endpoint_env" => "STG",
                               "manual_start_time_setting" => 33
                             })
      end

      it "has the correct endpoint env" do
        expect(endpoint_env.strip).to eq("stg")
      end

      context "when enpoint is wrong" do
        let(:vocdoni_env) { "WRONG" }

        it "defaults to dev" do
          expect(endpoint_env.strip).to eq("dev")
        end
      end
    end
  end
end
