# frozen_string_literal: true

class AddManualStartToDecidimVocdoniElections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_elections, :manual_start, :boolean, default: false
  end
end
