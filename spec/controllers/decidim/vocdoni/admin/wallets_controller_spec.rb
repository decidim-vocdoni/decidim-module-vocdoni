# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::WalletsController, type: :controller do
  routes { Decidim::Vocdoni::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, :admin) }
  let(:component) { create(:vocdoni_component) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
    sign_in user
  end

  describe "GET new" do
    let(:params) { { component_id: component.id } }

    it "renders the empty form" do
      get(:new, params:)
      expect(response).to have_http_status(:ok)
      expect(subject).to render_template(:new)
    end
  end

  describe "POST create" do
    let(:private_key) { "0xc6b8eb62f46d0863726410389d88b80be5d1e33672d841eaf2c7e395386fae53" }
    let(:params) do
      {
        current_organization: component.organization,
        current_user: user,
        private_key:
      }
    end

    it "creates a wallet" do
      post(:create, params:)

      expect(flash[:notice]).not_to be_empty
      expect(response).to have_http_status(:found)
    end

    it "redirects to that components' path" do
      post(:create, params:)

      expect(response.location).to match %r{/manage/$}
    end

    context "when there's redirect_back in the session" do
      it "redirects to that elections' steps path" do
        session[:redirect_back] = 1
        post(:create, params:)

        expect(response.location).to match %r{/manage/elections/1/steps$}
      end
    end
  end
end
