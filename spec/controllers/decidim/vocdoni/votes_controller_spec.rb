# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::VotesController do
  routes { Decidim::Vocdoni::Engine.routes }

  let(:component) { create(:vocdoni_component) }
  let(:election) { create(:vocdoni_election, :published, :started, component:) }
  let(:user) { create(:user, :confirmed, organization: component.organization) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
    sign_in user
  end

  describe "GET #new" do
    context "when vote is allowed" do
      before do
        allow(controller).to receive(:vote_allowed?).and_return(true)
      end

      it "renders the new template" do
        get :new, params: { election_id: election.id }
        expect(response).to render_template("new")
      end
    end
  end

  describe "POST check_verification" do
    let(:voter) { create(:vocdoni_voter, email: user.email, election:) }

    it "returns verification status" do
      post :check_verification, params: { election_id: election.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to eq({ isVerified: false, email: nil, election_id: election.id, token: nil, preview: false }.to_json)
    end

    context "when user is verified and is in the Vocdoni census" do
      before do
        allow(controller).to receive_messages(voter_verified?: true, voter:)
      end

      it "returns verification status" do
        post :check_verification, params: { election_id: election.id }
        expect(response).to have_http_status(:success)
        expect(response.body).to eq({ isVerified: true, email: voter.email, election_id: election.id, token: voter.token, preview: false }.to_json)
      end
    end

    context "when user is verified and is not in the Vocdoni census" do
      before do
        allow(controller).to receive_messages(voter_verified?: false, voter:)
      end

      it "returns verification status" do
        post :check_verification, params: { election_id: election.id }
        expect(response).to have_http_status(:success)
        expect(response.body).to eq({ isVerified: false, email: voter.email, election_id: election.id, token: voter.token, preview: false }.to_json)
      end
    end
  end

  describe "GET #votes_left" do
    it "returns the correct number of votes left" do
      get :votes_left, params: { election_id: election.id, votesLeft: 5 }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("You can vote again 5 times")
    end
  end
end
