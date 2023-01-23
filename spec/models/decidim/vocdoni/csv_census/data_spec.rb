# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::CsvCensus::Data do
  subject { csv_datum }

  let(:csv_datum) { create(:csv_datum) }

  it { is_expected.to be_valid }

  context "without a valid email" do
    let(:csv_datum) { build(:csv_datum, email: "invalid_email") }

    it { is_expected.not_to be_valid }
  end
end
