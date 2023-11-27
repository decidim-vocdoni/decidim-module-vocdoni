# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    describe Sdk do
      subject { described_class.new(organization, election) }
      let(:organization) { create :organization }
      let!(:wallet) { create :vocdoni_wallet, organization: organization, private_key: private_key }
      let!(:election) { create :vocdoni_election, organization: organization }
      let(:private_key) { "0x0000000000000000000000000000000000000000000000000000000000000001" }
      let(:salt) { Rails.application.secret_key_base }

      it "has a runner" do
        expect(subject.runner).to be_a(NodeRunner)
      end

      it "can generate a random wallet" do
        expect(subject.randomWallet).to match(/\A0x[a-zA-Z0-9]*\z/)
      end

      it "can generate a deterministic wallet" do
        expect(subject.deterministicWallet).to eq("0xc2b2820fe8e7ebe9ab139800d9da92588b77858f04907974baa534fad851ef5d")
        expect(subject.deterministicWallet("one parameter")).to eq("0x86dacaf5b85730e597b5eb0af57b279a68f8faad76eb1bff78d06631b02906db")
        expect(subject.deterministicWallet(["array 0", "array 1"])).to eq("0x56c63a4ba6f1c854ec5282d4a0c55761cb52f5d7f9f432d18c008fdc13c299a9")
      end

      it "has env variables" do
        expect(subject.env).to eq({
                                    "VOCDONI_WALLET_PRIVATE_KEY" => private_key,
                                    "VOCDONI_SALT" => salt,
                                    "VOCDONI_API_ENV" => "stg",
                                    "VOCDONI_ELECTION_ID" => election.id.to_s,
                                    "VOCDONI_WRAPPER_PATH" => "#{Decidim::Vocdoni::Engine.root}/node-wrapper"
                                  })
      end

      context "when wallet is not present" do
        let!(:wallet) { nil }

        it "has env variables" do
          expect(subject.env).to eq({
                                      "VOCDONI_WALLET_PRIVATE_KEY" => "",
                                      "VOCDONI_SALT" => salt,
                                      "VOCDONI_API_ENV" => "stg",
                                      "VOCDONI_ELECTION_ID" => election.id.to_s,
                                      "VOCDONI_WRAPPER_PATH" => "#{Decidim::Vocdoni::Engine.root}/node-wrapper"
                                    })
        end
      end

      context "when election is not present" do
        let!(:election) { nil }

        it "has env variables" do
          expect(subject.env).to eq({
                                      "VOCDONI_WALLET_PRIVATE_KEY" => private_key,
                                      "VOCDONI_SALT" => salt,
                                      "VOCDONI_API_ENV" => "stg",
                                      "VOCDONI_ELECTION_ID" => "",
                                      "VOCDONI_WRAPPER_PATH" => "#{Decidim::Vocdoni::Engine.root}/node-wrapper"
                                    })
        end
      end

      it "returns info" do
        expect(subject.info).to eq({
                                     "clientInfo" => {
                                       "address" => "7e5f4552091a69125d5dfcb7b8c2659029395bdf",
                                       "balance" => 50,
                                       "electionIndex" => 0,
                                       "metadata" => {
                                         "description" => { "default" => "" },
                                         "media" => {},
                                         "meta" => {},
                                         "name" => { "default" => "" },
                                         "newsFeed" => { "default" => "" },
                                         "version" => "1.0"
                                       },
                                       "nonce" => 0,
                                       "sik" => "fd921bbec1fdd59d08298498ccdc53b1fd208a3ef77a8bbaf8377642a35ff028"
                                     }
                                   })
      end

      it "throws exception on missing method" do
        expect { subject.nothing }.to(
          raise_error do |error|
            expect(error).to be_a(NodeRunnerError)
            expect(error.message).to eq("ReferenceError: nothing is not defined")
          end
        )
      end

      it "responds to missing method" do
        expect(subject.respond_to?(:randomWallet)).to be true
        expect(subject.respond_to?(:nothing)).to be false
      end

      context "when no node available" do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(NodeRunner::Executor).to receive(:binary).and_return(nil)
          # rubocop:enable RSpec/AnyInstance
        end

        it "raises RuntimeError with stacktrace" do
          expect { subject.randomWallet }.to(
            raise_error do |error|
              expect(error).to be_a(Sdk::NodeError)
              expect(error.message).to include("Permission denied - /tmp/node_runner")
            end
          )
        end
      end
    end
  end
end
