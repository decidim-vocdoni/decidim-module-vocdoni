# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This class holds a Form to create/update questions from Decidim's admin panel.
      class QuestionForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :weight, Integer, default: 0

        validates :title, translatable_presence: true

        def election
          @election ||= context[:election]
        end
      end
    end
  end
end
