# frozen_string_literal: true

module Decidim
  module Vocdoni
    class Voter < ApplicationRecord
      belongs_to :election, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Election", inverse_of: :voters

      validates :email, format: { with: ::Devise.email_regexp }
      validates :born_at, presence: true

      def self.inside(election)
        where(election: election)
      end

      def self.search_user_email(election, email)
        inside(election)
          .where(email: email)
          .order(created_at: :desc, id: :desc)
          .first
      end

      def self.insert_all(election, values)
        values.each { |value| create(email: value.first, election: election, born_at: value.second) }
      end

      def self.clear(election)
        inside(election).delete_all
      end
    end
  end
end
