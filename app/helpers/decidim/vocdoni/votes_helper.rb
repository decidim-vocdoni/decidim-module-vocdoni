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

      def votes_left_message(votes_left)
        scope = "decidim.vocdoni.votes.new"
        max_votes = Decidim::Vocdoni.votes_overwrite_max

        message_key, css_class = case votes_left
                                 when (2..max_votes)
                                   %w(can_vote_again secondary)
                                 when 1
                                   %w(can_vote_one_more_time warning)
                                 when 0
                                   %w(no_more_votes_left alert)
                                 end

        content_tag :div, t(message_key, scope: scope, votes_left: votes_left), class: "callout #{css_class} js-already_voted"
      end
    end
  end
end
