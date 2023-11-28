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

      # debug all http calls to a file
      class Executor < NodeRunner::Executor
        # uncomment to debug all http calls into development_app/node_debug.log
        # def exec(filename)
        #   ENV["NODE_PATH"] = @modules_path
        #   ENV["NODE_DEBUG"] = "http:*,http2:*"
        #   stdout, stderr, status = Open3.capture3("#{binary} #{filename}")
        #   open('node_debug.log', 'a') { |f| f.puts stderr }

        #   if status.success?
        #     stdout
        #   else
        #     raise exec_runtime_error(stderr)
        #   end
        # end
      end

      def self.runner(file = "index.js")
        javascript = File.read(wrapper_path(file))
        # customize the runner to handle promises
        NodeRunner.new(javascript, executor: Executor.new(runner_path: wrapper_path("node_runner.js")))
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
      attr_writer :runner

      def runner
        @runner ||= self.class.runner
      end

      def method_missing(function, *args)
        secrets_env.each do |key, value|
          ENV[key] = value
        end
        runner.send(function, *args)
      rescue Errno::EACCES => e
        raise NodeError, e.message
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
