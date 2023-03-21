# frozen_string_literal: true

require "decidim/vocdoni/election_status_changer"

namespace :decidim_vocdoni do
  desc "Change election status automatically in Vocdoni's component"
  task :change_election_status, [] => :environment do
    Decidim::Vocdoni::ElectionStatusChanger.new.run
  end
end
