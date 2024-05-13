class AddVersionsCountToDecidimVocdoniAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_answers, :versions_count, :integer, default: 0, null: false
  end
end
