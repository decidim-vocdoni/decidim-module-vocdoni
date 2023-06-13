# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::StepsWizardHelper do
  describe "#tab_class" do
    it "returns the correct class for the active tab" do
      tab_name = "questions"
      active_class = "questions"
      result = helper.tab_class(tab_name, active_class)
      expect(result).to eq("tabs-title is-active")
    end

    it "returns the correct class for a non-active tab" do
      tab_name = "census"
      active_class = "questions"
      result = helper.tab_class(tab_name, active_class)
      expect(result).to eq("tabs-title")
    end
  end

  describe "#tab_link_class" do
    it 'returns an empty string for the "questions" tab with a present election' do
      tab_name = "questions"
      election = double(present?: true)
      result = helper.tab_link_class(tab_name, election)
      expect(result).to eq("")
    end

    it 'returns "disabled" for the "questions" tab with a nil election' do
      tab_name = "questions"
      election = nil
      result = helper.tab_link_class(tab_name, election)
      expect(result).to eq("disabled")
    end
  end

  describe "#question_with_link" do
    let(:question) { double(title: "Test question") }
    let(:election) { double }

    it "returns the correct formatted question with link" do
      allow(helper).to receive(:translated_attribute).with(question.title).and_return("Test question")
      allow(helper).to receive(:edit_election_question_path).with(election, question).and_return("/elections/1/questions/1/edit")

      result = helper.question_with_link(question, election)
      expect(result).to have_link("Test question", href: "/elections/1/questions/1/edit")
    end
  end
end
