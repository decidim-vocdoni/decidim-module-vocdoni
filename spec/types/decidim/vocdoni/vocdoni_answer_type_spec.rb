# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Vocdoni
    describe VocdoniAnswerType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:vocdoni_election_answer) }

      it_behaves_like "attachable interface"

      it_behaves_like "traceable interface" do
        let(:author) { create(:user, :admin, organization: model.component.organization) }
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the answers weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end
    end
  end
end
