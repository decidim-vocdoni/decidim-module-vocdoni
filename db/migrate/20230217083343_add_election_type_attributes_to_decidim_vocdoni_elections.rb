class AddElectionTypeAttributesToDecidimVocdoniElections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_elections, :election_type, :jsonb, default: {}
  end
end
