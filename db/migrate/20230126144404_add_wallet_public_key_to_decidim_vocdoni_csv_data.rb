class AddWalletPublicKeyToDecidimVocdoniCsvData < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_csv_data, :wallet_public_key, :string
  end
end
