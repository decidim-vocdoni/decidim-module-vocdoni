# frozen_string_literal: true

class CreateDecidimVocdoniWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_vocdoni_wallets do |t|
      t.string :private_key
      t.references :decidim_organization, foreign_key: true, index: true
    end
  end
end
