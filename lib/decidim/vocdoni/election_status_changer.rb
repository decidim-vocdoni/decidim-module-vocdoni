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
        # rubocop:disable Rails/Output
        if elections.count.zero?
          puts "No elections to change to '#{status}' status"
          return
        end

        puts "Changing #{elections.count} election to '#{status}' status"
        # rubocop:enable Rails/Output
        # rubocop:disable Rails/SkipsModelValidations
        elections.update_all(status:)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
