# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This type represents an election Question.
    # The name is different from the model because the Question type is already defined on the Forms module.
    class VocdoniQuestionType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TraceableInterface

      description "A question for an election"

      field :id, GraphQL::Types::ID, "The internal ID of this question", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this question", null: false
      field :weight, GraphQL::Types::Int, "The ordering weight for this question", null: true
      field :answers, [Decidim::Vocdoni::VocdoniAnswerType, { null: true }], "The answers for this question", null: false
    end
  end
end
