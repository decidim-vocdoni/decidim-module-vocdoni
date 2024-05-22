# frozen_string_literal: true

require "node-runner"

# This is helper around the javascript SDK interface that runs with Node.js
# It reads the file from node-wrapper/index.js and translates every function in that file
# to an equivalent method in ruby
# Uses node-runner under the hood
# @see https://github.com/bridgetownrb/node-runner
module Decidim
  module Vocdoni
    class Sdk
      class NodeError < NodeRunnerError; end

      # Debug all HTTP calls to a file
      class Executor < NodeRunner::Executor
        # Set the env DECIDIM_VOCDONI_SDK_DEBUG=1 to debug all http calls into development_app/node_debug.log
        def exec(filename)
          return super(filename) unless ENV.fetch("DECIDIM_VOCDONI_SDK_DEBUG", false)

          ENV["NODE_PATH"] = @modules_path
          ENV["NODE_DEBUG"] = "http:*,http2:*"
          stdout, stderr, status = Open3.capture3("#{binary} #{filename}")
          open("node_debug.log", "a") { |f| f.puts stderr }

          raise exec_runtime_error(stderr) unless status.success?

          stdout
        end
      end

      def self.runner(file = "index.js")
        javascript = File.read(wrapper_path(file))
        # customize the runner to handle promises
        NodeRunner.new(javascript, executor: Executor.new(runner_path: wrapper_path("node_runner.js")))
      end

      def initialize(organization, election = nil)
        @organization = organization
        @secrets_env = {
          "VOCDONI_WALLET_PRIVATE_KEY" => Wallet.find_by(organization:)&.private_key.to_s,
          "VOCDONI_SALT" => Rails.application.secret_key_base,
          "VOCDONI_API_ENV" => Vocdoni.api_endpoint_env,
          "VOCDONI_ELECTION_ID" => election&.vocdoni_election_id.to_s,
          "VOCDONI_WRAPPER_PATH" => self.class.wrapper_path
        }
      end

      attr_reader :secrets_env, :organization, :last_error
      attr_writer :runner

      def runner
        @runner ||= self.class.runner
      end

      def method_missing(function, *args)
        Rails.logger.debug { "Vocdoni SDK: Calling #{function} with #{args}" }
        secrets_env.each do |key, value|
          ENV[key] = value
        end
        runner.send(function, *args)
      rescue Errno::EACCES => e
        raise NodeError, e.message
      rescue StandardError => e
        lines = e.message.split("\n")
        @last_error = lines.grep(/\[Error\]/).first
        @last_error = lines.grep(/ErrAPI/).first if @last_error.blank?
        @last_error = lines.first if @last_error.blank?
        raise
      end

      def respond_to_missing?(function, _include_private = false)
        JSON.parse(runner.to_json)["source"].include?("const #{function} = (")
      end

      def self.wrapper_path(filename = nil)
        parts = ["node-wrapper"]
        parts << filename.to_s if filename
        File.join(Decidim::Vocdoni::Engine.root, *parts)
      end
    end
  end
end
