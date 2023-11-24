# frozen_string_literal: true

require "node-runner"

# This is helper around the javascript SDK interface that runs with node
# Reads the file from node-wrapper/index.js and translates every function in that file
# to an equivalent method in ruby
# Uses https://github.com/bridgetownrb/node-runner under the hood
module Decidim
  module Vocdoni
    class Sdk
      class NodeError < NodeRunnerError; end

      def self.runner
        javascript = File.read("#{wrapper_path}/index.js")
        # customize the runner to handle promises
        NodeRunner.new(javascript, executor: NodeRunner::Executor.new(runner_path: "#{wrapper_path}/node_runner.js"))
      end

      def initialize(organization, election = nil)
        @organization = organization
        @secrets_env = {
          "VOCDONI_WALLET_PRIVATE_KEY" => Wallet.find_by(organization: organization)&.private_key.to_s,
          "VOCDONI_SALT" => Rails.application.secret_key_base,
          "VOCDONI_API_ENV" => Vocdoni.api_endpoint_env,
          "VOCDONI_ELECTION_ID" => election&.id.to_s,
          "VOCDONI_WRAPPER_PATH" => self.class.wrapper_path
        }
      end

      attr_reader :secrets_env, :organization

      def runner
        @runner ||= self.class.runner
      end

      def method_missing(function, *args)
        secrets_env.each do |key, value|
          ENV[key] = value
        end
        runner.send(function, args)
      rescue Errno::EACCES => e
        raise NodeError, e.message
      end

      def respond_to_missing?(function, _include_private = false)
        JSON.parse(runner.to_json)["source"].include?("const #{function} = (")
      end

      def self.wrapper_path
        File.join(Decidim::Vocdoni::Engine.root, "node-wrapper")
      end
    end
  end
end
