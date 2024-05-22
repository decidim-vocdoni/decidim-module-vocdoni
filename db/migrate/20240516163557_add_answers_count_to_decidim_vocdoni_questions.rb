# frozen_string_literal: true

class AddAnswersCountToDecidimVocdoniQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_questions, :answers_count, :integer, default: 0, null: false
  end
end
