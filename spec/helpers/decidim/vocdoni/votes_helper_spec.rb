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
    end
  end
end
