# frozen_string_literal: true

class AddDescriptionToDecidimVocdoniQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_questions, :description, :jsonb
  end
end
