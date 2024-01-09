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

        def all_wallets
          @all_wallets ||= Voter.inside(@election).distinct.select(:wallet_address).where.not(wallet_address: [nil, ""]).pluck(:wallet_address)
        end

        def percentage_complete
          return 0 if count.zero?

          ((count(:wallet_address) * 100) / count).to_i
        end

        def to_json(*_args)
          {
            name: name,
            electionId: @election.id,
            count: count,
            percentageComplete: percentage_complete,
            percentageText: I18n.t("status.percentage_complete", scope: "decidim.vocdoni.admin.census", count: count, percentage: percentage_complete),
            lastImportAt: last_import_at,
            pendingUpload: pending_upload?,
            pendingGeneration: pending_generation?,
            readyToSetup: ready_to_setup?
          }
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
          count(:wallet_address).positive? && count == count(:wallet_address)
        end
      end
    end
  end
end
