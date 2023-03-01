# frozen_string_literal: true

module Decidim
  module Vocdoni
    class ElectionStatusChanger
      def initialize(quiet: true)
        @quiet = quiet
      end

      def run
        update_ongoing_elections!
        update_finished_elections!
      end

      private

      attr_reader :quiet

      def update_ongoing_elections!
        elections = Decidim::Vocdoni::Election
                    .where(status: "created")
                    .where("start_time <= ?", Time.zone.now)
                    .where("end_time >= ?", Time.zone.now)
        update_elections_status(elections, "vote")
      end

      def update_finished_elections!
        elections = Decidim::Vocdoni::Election
                    .where(status: %w(created vote))
                    .where("end_time <= ?", Time.zone.now)
        update_elections_status(elections, "vote_ended")
      end

      def update_elections_status(elections, status)
        if elections.count.zero?
          Rails.logger.debug { "No elections to change to '#{status}' status" } unless quiet
          return
        end

        Rails.logger.debug { "Changing #{elections.count} election to '#{status}' status" } unless quiet
        # rubocop:disable Rails/SkipsModelValidations
        elections.update_all(status: status)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
