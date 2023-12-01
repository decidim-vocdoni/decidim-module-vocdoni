# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This class holds a Form to update the status of elections from Decidim's admin panel.
      class ElectionStatusForm < Decidim::Form
        attribute :status, String

        validates :status, inclusion: { in: %w(created paused vote canceled end) }
        validate :election_type_interruptible

        delegate :election, to: :context

        def current_step; end

        def main_button?
          election.vocdoni_election_id.blank?
        end

        private

        def election_type_interruptible
          errors.add(:election, :not_interruptible) unless context.election.election_type["interruptible"]
        end
      end
    end
  end
end
