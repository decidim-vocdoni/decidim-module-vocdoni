# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Question do
  subject(:question) { build(:vocdoni_question) }

  it { is_expected.to be_valid }

  include_examples "resourceable"
end
