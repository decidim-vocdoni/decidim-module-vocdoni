# frozen_string_literal: true

class AddCensusTypeDataToDecicidVocdoniElections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_elections, :census_type, :string
    add_column :decidim_vocdoni_elections, :verification_types, :string, array: true, default: []
  end
end
