# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Vocdoni
    describe VotesHelper do
      let(:question) { create :vocdoni_question, :complete, answers: 3 }

      let(:helper) do
        Class.new(ActionView::Base) do
          include VotesHelper
          include TranslatableAttributes
        end.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, [])
      end

      describe "more_information?" do
        let(:answer) { question.answers.first }
        let(:show_more_information) { helper.more_information?(answer) }

        context "when the answer has a description" do
          before do
            answer.description = { "en" => "Description" }
            answer.save!
          end

          it "returns true" do
            expect(show_more_information).to be_truthy
          end
        end

        context "when the answer has no description" do
          before do
            answer.description = {}
            answer.save!
          end

          it "returns false" do
            expect(show_more_information).to be_falsey
          end
        end
      end

      describe "votes_left_message" do
        let(:votes_left) { nil }

        let(:votes_left_message) { helper.votes_left_message(votes_left) }

        before do
          allow(Decidim::Vocdoni).to receive(:votes_overwrite_max).and_return(5)
        end

        context "when votes_left is greater than 1 and less than or equal to votes_overwrite_max" do
          let(:votes_left) { 3 }

          it "returns the 'can_vote_again' message" do
            expect(votes_left_message).to include(I18n.t("can_vote_again", scope: "decidim.vocdoni.votes.new", votes_left: votes_left))
          end
        end

        context "when votes_left is equal to 1" do
          let(:votes_left) { 1 }

          it "returns the 'can_vote_one_more_time' message" do
            expect(votes_left_message).to include(I18n.t("can_vote_one_more_time", scope: "decidim.vocdoni.votes.new"))
          end
        end

        context "when votes_left is 0 or less" do
          let(:votes_left) { 0 }

          it "returns the 'no_more_votes_left' message" do
            expect(votes_left_message).to include(I18n.t("no_more_votes_left", scope: "decidim.vocdoni.votes.new"))
          end
        end
      end
    end
  end
end
