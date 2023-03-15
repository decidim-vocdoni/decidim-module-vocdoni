# frozen_string_literal: true

class ChangeCensusFieldsOnDecidimVocodniVoters < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_voters, :token, :string
    remove_column :decidim_vocdoni_voters, :born_at, :date
  end
end
