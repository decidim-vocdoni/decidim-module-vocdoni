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
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Vocdoni::Election
          .where(status: "created")
          .where("start_time <= ?", Time.zone.now)
          .where("end_time >= ?", Time.zone.now)
          &.update_all(status: "vote")
        # rubocop:enable Rails/SkipsModelValidations
      end

      def update_finished_elections!
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::Vocdoni::Election
          .where(status: ["created", "vote"])
          .where("end_time <= ?", Time.zone.now)
          &.update_all(status: "vote_ended")
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
