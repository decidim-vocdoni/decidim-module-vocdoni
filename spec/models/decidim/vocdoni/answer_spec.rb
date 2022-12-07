# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Answer do
  subject(:answer) { build(:election_answer) }

  it { is_expected.to be_valid }

  include_examples "resourceable"
end
