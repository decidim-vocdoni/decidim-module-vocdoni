# frozen_string_literal: true

class AddCensusDataToDecidimVocdoniElections < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable Rails/ThreeStateBooleanColumn
    add_column :decidim_vocdoni_elections, :internal_census, :boolean, default: false
    add_column :decidim_vocdoni_elections, :verification_types, :string, array: true, default: []
    add_column :decidim_vocdoni_elections, :census_attributes, :jsonb, default: {}
    add_column :decidim_vocdoni_elections, :last_census_update_records_added, :integer
    add_column :decidim_vocdoni_elections, :census_last_updated_at, :datetime
    add_column :decidim_vocdoni_voters, :in_vocdoni_census, :boolean, default: false
    # rubocop:enable Rails/ThreeStateBooleanColumn
  end
end
