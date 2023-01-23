# frozen_string_literal: true

module Decidim
  module Vocdoni
    module CsvCensus
      class Status
        def initialize(election)
          @election = election
        end

        def last_import_at
          @last ||= CsvDatum.inside(@election).order(created_at: :desc).first
          @last ? @last.created_at : nil
        end

        def count
          @count ||= CsvDatum.inside(@election).distinct.count(:email)
        end
      end
    end
  end
end
