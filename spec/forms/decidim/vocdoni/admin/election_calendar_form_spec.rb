# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::ElectionCalendarForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_organization: organization,
      current_component: current_component
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :vocdoni_component, participatory_space: participatory_process }
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 3.days.from_now }
  let(:manual_start) { false }
  let(:attributes) do
    {
      start_time: start_time,
      end_time: end_time,
      manual_start: manual_start
    }
  end

  it { is_expected.to be_valid }

  describe "when start_time is missing" do
    let(:start_time) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when end_time is missing" do
    let(:end_time) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is after end_time" do
    let(:start_time) { end_time + 3.days }

    it { is_expected.not_to be_valid }
  end

  describe "when start_time is equal to start_time" do
    let(:start_time) { end_time }

    it { is_expected.not_to be_valid }
  end

  describe "when manual_start is true" do
    let(:manual_start) { true }

    it { is_expected.to be_valid }
  end

  describe "when manual_start is true and end_time is less than 1 hour from now" do
    let(:manual_start) { true }
    let(:end_time) { 1.hour.from_now }

    it { is_expected.not_to be_valid }
  end

  describe "when manual_start is true and end_time is equal to current time" do
    let(:manual_start) { true }
    let(:end_time) { Time.zone.now }

    it { is_expected.not_to be_valid }
  end
end
