# frozen_string_literal: true

module Decidim
  module Vocdoni
    # Common logic for the election cells and votes controller
    module VoterVerifications
      extend ActiveSupport::Concern

      included do
        def census_authorize_methods
          extend Decidim::UserProfile

          election_verification_types = election.verification_types

          @census_authorize_methods ||= available_verification_workflows.select do |workflow|
            election_verification_types.include?(workflow.name)
          end
        end

        def granted_authorizations
          @granted_authorizations ||= census_authorize_methods.select do |workflow|
            user_authorizations.include?(workflow.name)
          end
        end

        def user_authorizations
          Decidim::Verifications::Authorizations.new(
            organization: current_organization,
            user: current_user,
            granted: true
          ).query.pluck(:name)
        end

        def voter_verified?
          required_authorizations = census_authorize_methods.map(&:name)
          required_authorizations.present? && required_authorizations.all? { |auth| user_authorizations.include?(auth) }
        end

        def voter
          @voter ||= Decidim::Vocdoni::Voter.find_by(email: current_user.email, decidim_vocdoni_election_id: election.id)
        end
      end
    end
  end
end
