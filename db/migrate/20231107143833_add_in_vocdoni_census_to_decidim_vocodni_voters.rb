# frozen_string_literal: true

class AddInVocdoniCensusToDecidimVocodniVoters < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_voters, :in_vocdoni_census, :boolean, default: false
  end
end
