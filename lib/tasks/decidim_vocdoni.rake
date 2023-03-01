# frozen_string_literal: true

require "decidim/vocdoni/election_status_changer"

namespace :decidim_vocdoni do
  desc "Change election status automatically in Vocdoni's component"
  task :change_election_status, [:quiet] => :environment do |_task, args|
    quiet = args[:quiet] == "quiet"
    Decidim::Vocdoni::ElectionStatusChanger.new(quiet: quiet).run
  end
end
