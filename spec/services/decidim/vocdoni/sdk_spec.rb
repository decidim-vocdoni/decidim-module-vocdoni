# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    describe Sdk do
      subject { described_class.new(organization, election) }
      let(:organization) { election.organization }
      let!(:wallet) { create :vocdoni_wallet, organization: organization, private_key: private_key }
      let!(:election) { create :vocdoni_election }
      let(:private_key) { "0x0000000000000000000000000000000000000000000000000000000000000001" }
      let(:salt) { Rails.application.secret_key_base }

      it "has a runner" do
        expect(subject.runner).to be_a(NodeRunner)
      end

      it "can generate a random wallet" do
        expect(subject.randomWallet["address"]).to match(/\A0x[a-zA-Z0-9]*\z/)
      end

      it "can generate a deterministic wallet" do
        expect(subject.deterministicWallet).to eq({
                                                    "address" => "0x29C34740F7576fD843Dd91f9744e682c523A2632",
                                                    "privateKey" => "0x3de4d6d21c911126ec2d588618fd6d1f8c39b713767db589ab1df9ad6755e09f",
                                                    "publicKey" => "0x04a0ebc7ef99e34526422cb3711925f2bf271a8d4242bf3f0ed6962c439a8426960ce04145fdd73a8c579f5cb9966eabafe1f389f45790978b7cc38436e1041da9"
                                                  })
        expect(subject.deterministicWallet("one parameter")).to eq({
                                                                     "address" => "0xC8CE599F90705c221b0051893e4b8EdAFE8BB09B",
                                                                     "privateKey" => "0xfea463c58a66aefbd82dcf7799b324c47329938a93b02a02599ca3d79b226a76",
                                                                     "publicKey" => "0x04b45df6f4a84d992fd99cbc9ff7e5e0f94b2bbd2bd78e93ce998a4aa20be9cb89443a90df49836d17bcbc141e724e237091c7c901613d6bdf664b2cb3931b0d18"

                                                                   })
        expect(subject.deterministicWallet(["array 0", "array 1"])).to eq({
                                                                            "address" => "0x23DAb7E4BE5B2B5cA5EC78C6B8af5bCA9a048895",
                                                                            "privateKey" => "0x3f24361edf36cec500b4653799007e033b31464bb9c066145221eb6d72d5ccb4",
                                                                            "publicKey" => "0x0478c677013753e14dd93be48fa626e5d72e3910b091b7057c0fc1ea57aef16debc34688eef370c34a9d4164555ba0b300d1eb0d041b8be84d2994f570b7ac7e44"

                                                                          })
      end

      it "has env variables" do
        expect(subject.env).to eq({
                                    "VOCDONI_WALLET_PRIVATE_KEY" => private_key,
                                    "VOCDONI_SALT" => salt,
                                    "VOCDONI_API_ENV" => "dev",
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
                                      "VOCDONI_API_ENV" => "dev",
                                      "VOCDONI_ELECTION_ID" => election.id.to_s,
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
