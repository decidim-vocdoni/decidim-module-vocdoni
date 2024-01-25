# frozen_string_literal: true

class AddCensusTypeDataToDecicidVocdoniElections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_elections, :internal_census, :boolean, default: false
    add_column :decidim_vocdoni_elections, :verification_types, :string, array: true, default: []
    add_column :decidim_vocdoni_elections, :census_attributes, :jsonb, default: {}
  end
end
