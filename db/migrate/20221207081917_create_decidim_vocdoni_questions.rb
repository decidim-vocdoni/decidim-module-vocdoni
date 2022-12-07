# frozen_string_literal: true

class CreateDecidimVocdoniQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_vocdoni_questions do |t|
      t.references :decidim_vocdoni_election
      t.jsonb :title
      t.integer :weight

      t.timestamps
    end
  end
end
