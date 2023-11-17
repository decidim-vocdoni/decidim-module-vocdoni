# frozen_string_literal: true

module Decidim
  module Vocdoni
    module CsvCensus
      class Status
        def initialize(election)
          @election = election
        end

        def last_import_at
          @last ||= Voter.inside(@election).order(created_at: :desc).first
          @last ? @last.created_at : nil
        end

        def count(attribute = :email)
          Voter.inside(@election).distinct.count(attribute)
        end

        def name
          if pending_upload?
            "pending_upload"
          elsif pending_generation?
            "pending_generation"
          else
            "ready"
          end
        end

        def pending_upload?
          count.zero?
        end

        def pending_generation?
          count.positive? && count(:wallet_address).zero?
        end

        def ready_to_setup?
          return true if @election.internal_census? && @election.verification_types.empty?

          count(:wallet_address).positive? && count == count(:wallet_address)
        end
      end
    end
  end
end
