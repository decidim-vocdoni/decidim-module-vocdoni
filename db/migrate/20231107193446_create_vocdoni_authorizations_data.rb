# frozen_string_literal: true

class CreateVocdoniAuthorizationsData < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_vocdoni_authorizations_data do |t|
      t.references :authorization, null: false, foreign_key: { to_table: :decidim_authorizations }
      t.boolean :processed, default: false, null: false
      t.references :decidim_vocdoni_election, null: false, foreign_key: true, index: { name: "index_decidim_vocdoni_auth_data_on_election_id" }

      t.timestamps
    end
  end
end
