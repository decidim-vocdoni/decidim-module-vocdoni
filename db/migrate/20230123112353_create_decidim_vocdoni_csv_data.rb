class CreateDecidimVocdoniCsvData < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_vocdoni_csv_data do |t|
      t.string :email
      t.date :born_at

      t.references :decidim_vocdoni_election, foreign_key: true, index: true
      t.timestamps
    end
  end
end
