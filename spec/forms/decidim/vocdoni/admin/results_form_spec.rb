# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::ResultsForm do
  subject { described_class.from_params(attributes) }

  let(:attributes) do
    {
      results: [
        { id: 1, votes: 0 },
        { id: 2, votes: 100 }
      ]
    }
  end

  it { is_expected.to be_valid }

  describe "when votes are missing" do
    let(:attributes) do
    {
      results: [
        { id: 1, votes: 0 },
        { id: 2, votes: 0 }
      ]
    }
    end

    it { is_expected.not_to be_valid }
  end
end

