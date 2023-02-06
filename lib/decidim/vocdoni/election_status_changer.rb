# frozen_string_literal: true

module Decidim
  module Vocdoni
    class ElectionStatusChanger
      def run
        update_ongoing_elections!
        update_finished_elections!
      end

      private

      def update_ongoing_elections!
        Decidim::Vocdoni::Election.where(
          "start_time <= ? AND end_time >= ?", Time.zone.now, Time.zone.now
        )&.update_all(status: "vote")
      end

      def update_finished_elections!
        Decidim::Vocdoni::Election.where(
          "end_time <= ? AND status = ?", Time.zone.now, "vote"
        )&.update_all(status: "vote_ended")
      end
    end
  end
end
