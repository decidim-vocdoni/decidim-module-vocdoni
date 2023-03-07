# frozen_string_literal: true

class AddValuesToDecidimVocdoniAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_answers, :value, :integer
  end
end
