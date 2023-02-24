# frozen_string_literal: true

class AddVotesToDecidimVocdoniAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_vocdoni_answers, :votes, :integer
  end
end
