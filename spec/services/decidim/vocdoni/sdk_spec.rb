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
                                                    "address" => "0xa7a372881aDDEf67C6C0c2BDCd2fd013dcD859ea",
                                                    "privateKey" => "0x0c2c39585c9c0b47d2844a9d402a2446e8e7fce3908ef1a9287908316b959d6d",
                                                    "publicKey" => "0x04e66c18eb1487ffa051c4324163d002ef51c5d9451456d2c40dd77ece4cf4a803cab889c7a6763af8055355cadf3749c366fdf8307a6a919ff93cd27cfa1a2a44"
                                                  })
        expect(subject.deterministicWallet("one parameter")).to eq({
                                                                     "address" => "0xCf1f8ffa80456C43AEc18c8a3d97429a3248AA6C",
                                                                     "privateKey" => "0x86dacaf5b85730e597b5eb0af57b279a68f8faad76eb1bff78d06631b02906db",
                                                                     "publicKey" => "0x04ba0a538555a661ed637edc0d84db8129c37bd6b5861c51f46aae23aeedb436b570aab970315f8dc321c7648c39207eed43458b11e5b85294f77debe44d96675b"
                                                                   })
        expect(subject.deterministicWallet(["array 0", "array 1"])).to eq({
                                                                            "address" => "0xFD1A713E61cE2AbB50c73A897Eaf0bE386274bA7",
                                                                            "privateKey" => "0x56c63a4ba6f1c854ec5282d4a0c55761cb52f5d7f9f432d18c008fdc13c299a9",
                                                                            "publicKey" => "0x04468684d08872b8ba4939766f475c5ba28505174ef58cd03878182173c3c6f8c070f70c2762eac83b9fe25618566c9db76a169184828f6f778255c50cc1eecf43"
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
