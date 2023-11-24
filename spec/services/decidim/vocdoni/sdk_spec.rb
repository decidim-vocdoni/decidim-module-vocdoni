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
        expect(subject.deterministicWallet).to eq("0x4561187acaee0c0a9d28947f5f0a3619c38f4751485a07d0f9a696a062537e28")
        expect(subject.deterministicWallet("one parameter")).to eq("0x005861c26e225cf6276b44c8ac90ba3cb83ae5db25a8ccb5a484ecde3f7002dd")
        expect(subject.deterministicWallet(["array 0", "array 1"])).to eq("0x54c32aa638290fdcb1857c9148e4b6840f4bf6aaab06d1ea86106a3d1eb001e7")
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
