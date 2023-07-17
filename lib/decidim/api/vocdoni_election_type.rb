# frozen_string_literal: true

module Decidim
  module Vocdoni
    # This type represents a Vocdoni Election.
    #
    # As there's already a GraphQL type called Election (from the module decidim-elections)
    # we change the name to VodoniElection for the external API.
    # Note that internally there aren't any colition as Ruby has namespaces, meaning that
    # Decidim::Vocdoni::Election and Decidim::Vocdoni::Election isn't the same thing.
    class VocdoniElectionType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface

      description "An election"

      field :id, GraphQL::Types::ID, "The internal ID of this election", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this election", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description for this election", null: false
      field :stream_uri, GraphQL::Types::String, "The stream URI for this election", null: true, camelize: true
      field :auto_start, GraphQL::Types::Boolean, "Whether this election will start automatically or manually", method: :auto_start?, null: true
      field :dynamic_census, GraphQL::Types::Boolean, "Whether the census is closed or dynamic", method: :dynamic_census?, null: true
      field :start_time, Decidim::Core::DateTimeType, "The start time for this election", null: true
      field :end_time, Decidim::Core::DateTimeType, "The end time for this election", null: false
      field :created_at, Decidim::Core::DateTimeType, "When this election was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this election was updated", null: true
      field :published_at, Decidim::Core::DateTimeType, "When this election was published", null: true
      field :blocked, GraphQL::Types::Boolean, "Whether this election has it's parameters blocked or not", method: :blocked?, null: true
      field :status, GraphQL::Types::String, "The status for this election", null: true, camelize: false
      field :interruptible, GraphQL::Types::Boolean, "Whether this election has have the 'interruptible' setting enabled", method: :interruptible?, null: true
      field :secret_until_the_end, GraphQL::Types::Boolean, "Whether this election has the 'votes secret until the end' setting enabled", method: :secret_until_the_end?, null: true

      field :questions, [Decidim::Vocdoni::VocdoniQuestionType, { null: true }], "The questions for this election", null: false
      field :voters, [Decidim::Vocdoni::VocdoniVoterType, { null: true }], "The voters for this election", null: false
    end
  end
end
