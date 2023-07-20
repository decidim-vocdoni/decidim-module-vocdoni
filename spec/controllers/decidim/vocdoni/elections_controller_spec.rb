# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::ElectionsController, type: :controller do
  routes { Decidim::Vocdoni::Engine.routes }

  let(:component) { create(:vocdoni_component) }
  let(:election) { create(:vocdoni_election, :published, component: component) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:wallet) { create(:wallet, organization: component.organization, private_key: Faker::Blockchain::Ethereum.address) }
  let(:vocdoni_client) { double("VocdoniClient") }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
  end

  describe "GET #show" do
    before { sign_in user }

    context "when election is not secret until the end and has data and is ongoing" do
      let(:election) do
        create(:vocdoni_election, :published, :ongoing, component: component, election_type: { "secret_until_the_end" => false })
      end

      before do
        allow(controller).to receive(:election_data).and_return({ data: "test" })
        allow(election).to receive(:finished?).and_return(false)
      end

      it "sets election data" do
        get :show, params: { id: election.id }
        expect(assigns(:election_data)).to eq({ data: "test" })
      end
    end

    context "when request format is json" do
      before { sign_in user }

      it "renders correct json" do
        get :show, params: { id: election.id }, format: :json
        expect(JSON.parse(response.body)).to eq({ "election_data" => nil })
      end
    end
  end

  describe "#current_vocdoni_wallet" do
    it "returns the vocdoni wallet for current organization" do
      expect(controller.send(:current_vocdoni_wallet)).to eq(wallet)
    end
  end

  describe "#api_endpoint_env" do
    before { allow(Decidim::Vocdoni).to receive(:api_endpoint_env).and_return("stg") }

    it "returns api endpoint environment" do
      expect(controller.send(:api_endpoint_env)).to eq("stg")
    end
  end

  describe "#vocdoni_client" do
    before do
      allow(Decidim::Vocdoni::VocdoniClient).to receive(:new).with(wallet: wallet.private_key, api_endpoint_env:
        "api_env").and_return(vocdoni_client)
      allow(Decidim::Vocdoni).to receive(:api_endpoint_env).and_return("api_env")
    end

    it "returns a VocdoniClient instance" do
      expect(controller.send(:vocdoni_client)).to eq(vocdoni_client)
    end
  end

  describe "#vocdoni_election_id" do
    context "when election is not started" do
      let(:election) { create(:vocdoni_election, :published, component: component) }

      it "returns nil" do
        get :show, params: { id: election.id }
        expect(controller.send(:vocdoni_election_id)).to be_nil
      end
    end

    context "when election is ongoing" do
      let(:election) { create(:vocdoni_election, :ongoing, :published, component: component, vocdoni_election_id: "123") }

      it "returns the vocdoni election id" do
        get :show, params: { id: election.id }
        expect(controller.send(:vocdoni_election_id)).to eq("123")
      end
    end
  end

  describe "#election_data" do
    context "when election is not started" do
      let(:election) { create(:vocdoni_election, :published, component: component) }

      before do
        stub_request(:get, "https://api-stg.vocdoni.net/v2/elections/")
          .to_return(status: 200, body: nil, headers: {})
      end

      it "returns nil" do
        get :show, params: { id: election.id }
        expect(controller.send(:election_data)).to be_nil
      end
    end

    context "when election is ongoing" do
      let(:election) { create(:vocdoni_election, :ongoing, :published, component: component, vocdoni_election_id: "123") }
      let(:election_data) { { data: "election data" } }

      before do
        allow(Decidim::Vocdoni::VocdoniClient).to receive(:new).with(wallet: wallet.private_key, api_endpoint_env: "stg").and_return(vocdoni_client)
        allow(vocdoni_client).to receive(:fetch_election).with("123").and_return(election_data)
        allow(Decidim::Vocdoni).to receive(:api_endpoint_env).and_return("stg")
      end

      it "returns the election data" do
        get :show, params: { id: election.id }
        expect(controller.send(:election_data)).to eq(election_data)
      end
    end
  end
end
