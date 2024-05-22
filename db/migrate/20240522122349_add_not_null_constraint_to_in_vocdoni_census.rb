# frozen_string_literal: true

class AddNotNullConstraintToInVocdoniCensus < ActiveRecord::Migration[6.1]
  def change
    change_column_null :decidim_vocdoni_voters, :in_vocdoni_census, false
  end
end
