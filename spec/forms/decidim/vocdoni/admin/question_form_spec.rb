# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::QuestionForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election: election
    }
  end
  let(:election) { create :vocdoni_election }
  let(:component) { election.component }
  let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:description) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:weight) { 10 }
  let(:attributes) do
    {
      title: title,
      description: description,
      weight: weight
    }
  end

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { ca: nil, es: nil } }

    it { is_expected.to be_valid }
  end
end
