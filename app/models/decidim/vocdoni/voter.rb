# frozen_string_literal: true

module Decidim
  module Vocdoni
    class Voter < ApplicationRecord
      belongs_to :election, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Election", inverse_of: :voters

      validates :email, format: { with: ::Devise.email_regexp }
      validates :token, presence: true

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
        values.each { |value| create(email: value.first.downcase, election: election, token: value.second.downcase) }
      end

      def self.insert_participants_with_permissions(election, emails, token)
        emails.flatten.each { |email| create(email: email.downcase, election: election, token: token) }
      end

      def self.clear(election)
        inside(election).delete_all
      end
    end
  end
end
