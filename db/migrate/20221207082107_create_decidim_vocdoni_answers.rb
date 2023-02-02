# frozen_string_literal: true

class CreateDecidimVocdoniAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_vocdoni_answers do |t|
      t.references :decidim_vocdoni_question
      t.jsonb :title
      t.jsonb :description
      t.integer :weight

      t.timestamps
    end
  end
end
