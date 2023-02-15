# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::StepsHelper do
  describe "#steps" do
    subject { helper.steps(current_step) }

    let(:current_step) { "create_election" }

    it {
      expect(subject).to eq([
                              ["create_election", "text-warning"],
                              ["created", "text-muted"],
                              ["vote", "text-muted"],
                              ["vote_ended", "text-muted"],
                              ["results_published", "text-muted"]
                            ])
    }

    context "when current_step is ready to vote" do
      let(:current_step) { "vote" }

      it {
        expect(subject).to eq([
                                ["create_election", "text-success"],
                                ["created", "text-success"],
                                ["vote", "text-warning"],
                                ["vote_ended", "text-muted"],
                                ["results_published", "text-muted"]
                              ])
      }
    end

    context "when current_step is results_published" do
      let(:current_step) { "results_published" }

      it {
        expect(subject).to eq([
                                ["create_election", "text-success"],
                                ["created", "text-success"],
                                ["vote", "text-success"],
                                ["vote_ended", "text-success"],
                                ["results_published", "text-warning"]
                              ])
      }
    end
  end
end
