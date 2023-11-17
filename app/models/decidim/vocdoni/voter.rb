# frozen_string_literal: true

module Decidim
  module Vocdoni
    class Voter < ApplicationRecord
      belongs_to :election, foreign_key: "decidim_vocdoni_election_id", class_name: "Decidim::Vocdoni::Election", inverse_of: :voters

      validates :email, format: { with: ::Devise.email_regexp }
      validates :email, uniqueness: { scope: :decidim_vocdoni_election_id }
      validates :token, presence: true
      validates :in_vocdoni_census, inclusion: { in: [true, false] }

      after_save :update_in_vocdoni_census!, if: :saved_change_to_wallet_address?

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

      def self.clear(election)
        inside(election).delete_all
      end

      def update_in_vocdoni_census!
        self.in_vocdoni_census = wallet_address.present?
        save! if changed?
      end

      def sent_to_vocdoni?
        in_vocdoni_census
      end
    end
  end
end
