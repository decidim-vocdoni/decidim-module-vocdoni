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

        return if votes_left > max_votes

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

      def identification_title(election)
        title = election.internal_census? ? "title" : "login_title"
        content_tag(:h1, t("decidim.vocdoni.votes.check_census.#{title}"), class: "heading2").html_safe
      end

      def identification_description(election)
        key_suffix = if election.verification_types.empty? || (!voter_not_yet_in_census? && election.internal_census?)
                       "verifications_check"
                     elsif voter_not_yet_in_census? && election.internal_census?
                       "with_verifications"
                     else
                       "description"
                     end
        t("decidim.vocdoni.votes.check_census.#{key_suffix}")
      end
    end
  end
end
