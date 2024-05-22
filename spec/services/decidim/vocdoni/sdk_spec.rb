# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    describe Sdk do
      subject { described_class.new(organization, election) }
      let(:organization) { election.organization }
      let!(:wallet) { create(:vocdoni_wallet, organization:, private_key:) }
      let!(:election) { create(:vocdoni_election, vocdoni_election_id:) }
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
                                                    "address" => "0x5747fbA7EAc126176e7EDBBd0CaacFC26f6770E0",
                                                    "privateKey" => "0x019726c6babc1de231f26fd6cbb2df2c912784a2e1ba55295496269a6d3ff651",
                                                    "publicKey" => "0x04b95585db8921a0cc94200c83463c8ad43edc9fb3214accf5b4c49731ef96c7ff424d7ce7a764355b38af56afa3c38e7d588148e1a85acd64d5e5cc79942ee041"
                                                  })
        expect(subject.deterministicWallet("one parameter")).to eq({
                                                                     "address" => "0x031f6cF902FbfD87D305eA05702201F30c8503B9",
                                                                     "privateKey" => "0x474bb92a5c7c525225abdfdd63611c4e7b23306fbe40f70db4533f06d177ba0f",
                                                                     "publicKey" => "0x04c79bafda0295523e5d9aa5dffe2360af10c36ef2a0310b71064880ca2253dd04324bac92b05f0f25b83bd5c36f7d77e5de4766ccf035f6c91c31c5f873df8571"
                                                                   })
        expect(subject.deterministicWallet(["array 0", "array 1"])).to eq({
                                                                            "address" => "0x22C3174a986A5c60ADfe12149b3c4762987a8C70",
                                                                            "privateKey" => "0xa8ab766416e930db53996985218b3adf894e0cabb9a7261de375c25ad1618693",
                                                                            "publicKey" => "0x0461912971112e85aae89e8f586ab2b81397439d0f8d8efd369d806ab6b049f132c928d902d92d96bb2e6e59800d9d1e26e725e348a83e222bdbf4c7e4e1d374f3"
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
        let(:organization) { create(:organization) }

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
                                       "balance" => 10_000,
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
              expect(error.message).to include("Permission denied")
            end
          )
        end
      end
    end
  end
end
