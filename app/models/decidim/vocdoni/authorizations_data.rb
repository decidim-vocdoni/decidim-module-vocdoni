# frozen_string_literal: true

module Decidim
  module Vocdoni
    # app/models/vocdoni_authorizations_data.rb
    class AuthorizationsData < ApplicationRecord
      belongs_to :authorization, class_name: "Decidim::Authorization"
      belongs_to :election, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Election"

      attribute :processed, :boolean, default: false

      validates :processed, inclusion: { in: [true, false] }
    end
  end
end
