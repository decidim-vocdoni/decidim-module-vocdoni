# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::AuthorizationsData, type: :model do
  subject { build :vocdoni_authorizations_data, election: election, authorization: authorization, processed: processed }

  let(:authorization) { create :authorization, user: user }
  let(:user) { create :user, :confirmed }
  let(:election) { create :vocdoni_election }
  let(:processed) { true }

  describe "associations" do
    it "belongs to authorization" do
      expect(subject.authorization).to eq(authorization)
    end

    it "belongs to election" do
      expect(subject.election).to eq(election)
    end
  end

  describe "validations" do
    context "when processed is true" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when processed is false" do
      let(:processed) { false }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when processed is nil" do
      let(:processed) { nil }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:processed]).to include("is not included in the list")
      end
    end
  end
end
