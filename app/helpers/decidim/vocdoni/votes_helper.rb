# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Custom helpers for the voting booth views.
    #
    module VotesHelper
      def ordered_answers(question)
        question.answers.sort_by { |answer| [answer.weight, answer.id] }
      end

      def more_information?(answer)
        translated_attribute(answer.description).present?
      end

      def votes_left_message(voter, election)
        votes_left = Decidim::Vocdoni.votes_overwrite_max - voter.votes_count(election)
        scope = "decidim.vocdoni.votes.new"

        if votes_left > 1
          content_tag :div, t("can_vote_again", scope: scope), class: "callout secondary js-already_voted"
        elsif votes_left == 1
          content_tag :div, t("can_vote_one_more_time", scope: scope), class: "callout warning js-already_voted"
        else
          content_tag :div, t("no_more_votes_left", scope: scope), class: "callout alert js-already_voted"
        end
      end
    end
  end
end
