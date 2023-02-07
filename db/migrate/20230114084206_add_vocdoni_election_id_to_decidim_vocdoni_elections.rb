class AddVocdoniElectionIdToDecidimVocdoniElections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_elections, :vocdoni_election_id, :string
  end
end
