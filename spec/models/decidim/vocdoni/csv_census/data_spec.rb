# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::CsvCensus::Data do
  subject { voter }

  let(:voter) { create(:voter) }

  it { is_expected.to be_valid }

  context "without a valid email" do
    let(:voter) { build(:voter, email: "invalid_email") }

    it { is_expected.not_to be_valid }
  end
end
