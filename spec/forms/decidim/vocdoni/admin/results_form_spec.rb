# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::ResultsForm do
  subject { described_class.from_params({}) }

  it { is_expected.to be_valid }

  it "has main button" do
    expect(subject).to be_main_button
  end
end
