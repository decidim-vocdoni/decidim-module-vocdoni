# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::ElectionsController do
  routes { Decidim::Vocdoni::Engine.routes }

  let(:component) { create(:vocdoni_component) }
  let(:election) { create(:vocdoni_election, :published, component:) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }
  let!(:wallet) { create(:vocdoni_wallet, organization: component.organization, private_key: Faker::Blockchain::Ethereum.address) }
  let(:vocdoni_client) { double("Api") }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
  end

  describe "GET #show" do
    before { sign_in user }

    context "when election is not secret until the end and has data and is ongoing" do
      let(:election) do
        create(:vocdoni_election, :published, :ongoing, component:, election_type: { "secret_until_the_end" => false })
      end

      before do
        allow(controller).to receive(:election_metadata).and_return({ data: "test" })
        allow(election).to receive(:ongoing?).and_return(true)
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
        expect(response.parsed_body).to eq({ "election_data" => nil })
      end
    end
  end

  describe "#vocdoni_client" do
    before do
      allow(Decidim::Vocdoni::Api).to receive(:new)
        .with(vocdoni_election_id: election.vocdoni_election_id)
        .and_return(vocdoni_client)
    end

    it "returns a Api instance" do
      get :show, params: { id: election.id }
      expect(controller.send(:vocdoni_client)).to eq(vocdoni_client)
    end
  end

  describe "#election_metadata" do
    context "when election is ongoing and not secret until the end" do
      let(:election) do
        create(:vocdoni_election, :published, :ongoing, component:,
                                                        election_type: { "secret_until_the_end" => false },
                                                        vocdoni_election_id: "123")
      end
      let(:election_metadata) { { data: "election metadata" } }

      before do
        allow(Decidim::Vocdoni::Api).to receive(:new)
          .with(vocdoni_election_id: election.vocdoni_election_id)
          .and_return(vocdoni_client)
        allow(vocdoni_client).to receive(:fetch_election).and_return(election_metadata)
      end

      it "returns the election data" do
        get :show, params: { id: election.id }
        expect(controller.send(:election_metadata)).to eq(election_metadata)
      end
    end

    context "when election is not ongoing or is secret until the end" do
      let(:election) do
        create(:vocdoni_election, :published, component:,
                                              election_type: { "secret_until_the_end" => true })
      end

      it "returns nil" do
        get :show, params: { id: election.id }
        expect(controller.send(:election_metadata)).to be_nil
      end
    end
  end
end
