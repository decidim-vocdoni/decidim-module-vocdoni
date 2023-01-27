# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Vocdoni
    describe VocdoniVoterType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:voter, :with_credentials) }

      describe "wallet_public_key" do
        let(:query) { "{ wallet_public_key }" }

        it "returns all the required fields" do
          expect(response).to include("wallet_public_key" => model.wallet_public_key.to_s)
        end
      end
    end
  end
end
