# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Vocdoni
    describe VocdoniVoterType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:vocdoni_voter, :with_credentials) }

      describe "wallet_address" do
        let(:query) { "{ wallet_address }" }

        it "returns all the required fields" do
          expect(response).to include("wallet_address" => model.wallet_address.to_s)
        end
      end
    end
  end
end
