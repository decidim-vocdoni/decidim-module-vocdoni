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
                                ["create_election", "is-complete"],
                                ["created", "is-complete"],
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
                                ["create_election", "is-complete"],
                                ["created", "is-complete"],
                                ["vote", "is-complete"],
                                ["vote_ended", "is-complete"],
                                ["results_published", "text-warning"]
                              ])
      }
    end

    context "when current_step is paused" do
      let(:current_step) { "paused" }

      it {
        expect(subject).to eq([
                                ["create_election", "is-complete"],
                                ["created", "is-complete"],
                                ["vote", "is-complete"],
                                ["paused", "text-warning"],
                                ["vote_ended", "text-muted"],
                                ["results_published", "text-muted"]
                              ])
      }
    end

    context "when current_step is canceled" do
      let(:current_step) { "canceled" }

      it {
        expect(subject).to eq([
                                ["create_election", "is-complete"],
                                ["created", "is-complete"],
                                ["vote", "is-complete"],
                                ["canceled", "text-warning"]
                              ])
      }
    end
  end

  describe "#fix_it_button_with_icon" do
    subject { helper.fix_it_button_with_icon(link, icon) }

    let(:link) { "/admin/participatory_processes/123/elections/2/edit/" }
    let(:icon) { "tools-line" }

    it "generates the fix it button with icon" do
      expect(subject).to have_link("Fix it", href: link, class: "button button__xs")
      expect(subject).to have_css("svg[role='img'] use[href*='ri-tools-line']")
    end
  end
end
