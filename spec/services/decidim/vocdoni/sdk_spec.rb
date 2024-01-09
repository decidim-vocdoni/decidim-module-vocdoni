# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    describe Sdk do
      subject { described_class.new(organization, election) }
      let(:organization) { election.organization }
      let!(:wallet) { create :vocdoni_wallet, organization: organization, private_key: private_key }
      let!(:election) { create :vocdoni_election, vocdoni_election_id: vocdoni_election_id }
      let(:vocdoni_election_id) { "0x0000000000000000000000000000000000000001" }
      let(:private_key) { "0x0000000000000000000000000000000000000000000000000000000000000001" }
      let(:salt) { Rails.application.secret_key_base }

      before do
        allow(Rails.application).to receive(:secret_key_base).and_return("a-secret-key-base")
      end

      it "has a runner" do
        expect(subject.runner).to be_a(NodeRunner)
      end

      it "can generate a random wallet" do
        expect(subject.randomWallet["address"]).to match(/\A0x[a-fA-F0-9]*\z/)
      end

      it "can generate a deterministic wallet" do
        expect(subject.deterministicWallet).to eq({
                                                    "address" => "0x287bB1F264E11aF871d9c0C32F6bc1Bc59f811dD",
                                                    "privateKey" => "0x6d166f16c5b5acf8472eb1e6e7d3c366adc38d7f651a203dbd978cfe6ff3c853",
                                                    "publicKey" => "0x043160d65e3ce0090183a9ec8a1fc43fc2677e0c7d61609dad27dcb5460c5e1f9f9e3c35177ee441164df3052a6adb85cc9f977e0d4fcf6f4b3c365791728c3d32"
                                                  })
        expect(subject.deterministicWallet("one parameter")).to eq({
                                                                     "address" => "0xD5c53CD9080C2c5bF0Ac29029A66ce51b560A3c7",
                                                                     "privateKey" => "0xd92e6ff88ebfe3aa646b5bfcce7a1cd0e879646782bdba2131ac0e64055318be",
                                                                     "publicKey" => "0x0472c8bc391802be3b7d612fb36dc4aa170736e1aea09512216bfd8f3942e3f8ad522cc0db214072123328dd36a2cecb9281cfe3906aa739d186ba0c16249fb2bc"
                                                                   })
        expect(subject.deterministicWallet(["array 0", "array 1"])).to eq({
                                                                            "address" => "0xFa62E4A17D20174e44Aaa1Ad8f075c7CdD65ee77",
                                                                            "privateKey" => "0xf8986555559e7839baacf121f0d68e6fc7efa34792fa763a52e25afa44e288b4",
                                                                            "publicKey" => "0x04312dad046327f763fbaa0b6bae75910e78805d15825d2ad1a9884de879c2a06a63ed33c726fa358a022da7d5a631f1489c71da3e255ce70acaec96a7e7cb9276"
                                                                          })
      end

      it "has env variables" do
        expect(subject.env).to eq({
                                    "VOCDONI_WALLET_PRIVATE_KEY" => private_key,
                                    "VOCDONI_SALT" => salt,
                                    "VOCDONI_API_ENV" => "dev",
                                    "VOCDONI_ELECTION_ID" => vocdoni_election_id,
                                    "VOCDONI_WRAPPER_PATH" => "#{Decidim::Vocdoni::Engine.root}/node-wrapper"
                                  })
      end

      context "when wallet is not present" do
        let!(:wallet) { nil }

        it "has env variables" do
          expect(subject.env).to eq({
                                      "VOCDONI_WALLET_PRIVATE_KEY" => "",
                                      "VOCDONI_SALT" => salt,
                                      "VOCDONI_API_ENV" => "dev",
                                      "VOCDONI_ELECTION_ID" => vocdoni_election_id,
                                      "VOCDONI_WRAPPER_PATH" => "#{Decidim::Vocdoni::Engine.root}/node-wrapper"
                                    })
        end
      end

      context "when election is not present" do
        let!(:election) { nil }
        let(:organization) { create :organization }

        it "has env variables" do
          expect(subject.env).to eq({
                                      "VOCDONI_WALLET_PRIVATE_KEY" => private_key,
                                      "VOCDONI_SALT" => salt,
                                      "VOCDONI_API_ENV" => "dev",
                                      "VOCDONI_ELECTION_ID" => "",
                                      "VOCDONI_WRAPPER_PATH" => "#{Decidim::Vocdoni::Engine.root}/node-wrapper"
                                    })
        end
      end

      it "returns info" do
        expect(subject.info).to eq({
                                     "clientInfo" => {
                                       "address" => "7e5f4552091a69125d5dfcb7b8c2659029395bdf",
                                       "balance" => 500,
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

      context "when an election" do
        let(:census) { ["0x0000000000000000000000000000000000000000"] }
        let(:questions) do
          [[
            "Ain't this process awesome?",
            "Question description",
            [
              {
                title: "Yes",
                value: 0
              },
              {
                title: "No",
                value: 1
              }
            ]
          ]]
        end
        let(:json) { election.to_vocdoni }
        let(:data) { subject.election(json, questions, census)["election"] }

        it "formats an election" do
          expect(data["title"]).to eq(json["title"])
          expect(data["description"]).to eq(json["description"])
          expect(Time.zone.parse(data["startDate"])).to eq(Time.zone.parse(json["startDate"]))
          expect(Time.zone.parse(data["endDate"])).to eq(Time.zone.parse(json["endDate"]))
          expect(data["electionType"]).to eq(json["electionType"])
          expect(data["questions"]).to eq([{
                                            "title" => { "default" => "Ain't this process awesome?" },
                                            "description" => { "default" => "Question description" },
                                            "choices" => [
                                              { "title" => { "default" => "Yes" }, "value" => 0 },
                                              { "title" => { "default" => "No" }, "value" => 1 }
                                            ]
                                          }])
        end
      end

      it "throws exception on missing method" do
        expect { subject.nothing }.to(
          raise_error do |error|
            expect(error).to be_a(NodeRunnerError)
            expect(error.message).to eq("ReferenceError: nothing is not defined")
            expect(subject.last_error).to eq("ReferenceError: nothing is not defined")
          end
        )
      end

      context "when an Vocdoni [Error] error" do
        before do
          allow(subject.runner).to receive(:something).and_raise(StandardError.new("line 1\n[Error]: The election has already been created\nline 2"))
        end

        it "throws exception on missing method" do
          expect { subject.something }.to(
            raise_error do |error|
              expect(error.message).to eq("line 1\n[Error]: The election has already been created\nline 2")
              expect(subject.last_error).to eq("[Error]: The election has already been created")
            end
          )
        end
      end

      context "when an Vocdoni ErrAPI error" do
        before do
          allow(subject.runner).to receive(:something).and_raise(StandardError.new("line 1\nErrAPI: Error: The election has already been created\nline 2"))
        end

        it "throws exception on missing method" do
          expect { subject.something }.to(
            raise_error do |error|
              expect(error.message).to eq("line 1\nErrAPI: Error: The election has already been created\nline 2")
              expect(subject.last_error).to eq("ErrAPI: Error: The election has already been created")
            end
          )
        end
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
