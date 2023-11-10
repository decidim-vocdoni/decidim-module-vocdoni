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

      def render_internal_census(authorized_method, granted_authorizations)
        content = capture do
          render partial: "internal_census", locals: { authorized_method: authorized_method, granted: granted_authorizations.include?(authorized_method) }
        end

        if granted_authorizations.include?(authorized_method)
          content
        else
          link_to authorized_method.root_path(redirect_url: nil) do
            content
          end
        end
      end
    end
  end
end
