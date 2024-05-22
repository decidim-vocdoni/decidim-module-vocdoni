# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::ElectionCalendarController do
  routes { Decidim::Vocdoni::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
    sign_in user
  end

  describe "PATCH update" do
    let(:datetime_format) { I18n.t("time.formats.decidim_short") }
    let(:component) { create(:vocdoni_component) }
    let(:election) { create(:vocdoni_election, component:) }
    let(:election_params) do
      {
        start_time: election.start_time.strftime(datetime_format),
        end_time: election.end_time.strftime(datetime_format)
      }
    end
    let(:params) do
      {
        election_id: election.id,
        id: election.id,
        election_calendar: {
          start_time: election.start_time.strftime(datetime_format),
          end_time: election.end_time.strftime(datetime_format)
        }
      }
    end

    it "updates the election" do
      allow(controller).to receive(:publish_page_election_path).with(election).and_return("/elections/#{election.id}/publish_page")

      patch(:update, params:)

      expect(response).to have_http_status(:found)
    end
  end
end
