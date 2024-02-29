# frozen_string_literal: true

# This migration comes from decidim_vocdoni (originally 20240131162223)

class AddCensusTrackingToDecidimVocdoniElections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_elections, :last_census_update_records_added, :integer
    add_column :decidim_vocdoni_elections, :census_last_updated_at, :datetime
  end
end
