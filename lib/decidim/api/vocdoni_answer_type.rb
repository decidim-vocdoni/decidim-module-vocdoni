# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This type represents an answer to an election question.
    # The name is different from the model because to enforce consistency with Question type name.
    class VocdoniAnswerType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface

      description "An answer for an election's question"

      field :id, GraphQL::Types::ID, "The internal ID of this answer", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this answer", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description for this answer", null: true
      field :weight, GraphQL::Types::Int, "The ordering weight for this answer", null: true

      # field :results, [Decidim::Vocdoni::VocdoniResultType, { null: true }], "The voting results related to this answer", null: true
    end
  end
end
