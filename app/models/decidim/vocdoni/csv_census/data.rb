# frozen_string_literal: true

require "csv"

module Decidim
  module Vocdoni
    module CsvCensus
      # A data processor for get emails data form a csv file
      #
      # Enable this methods:
      #
      # - .error with an array of rows with errors in the csv file
      # - .values an array with emails readed from the csv file
      #
      # Returns nothing
      class Data
        attr_reader :errors, :values

        def initialize(file)
          @file = file
          @values = []
          @errors = []

          CSV.foreach(@file, col_sep: ";", headers: true, encoding: "BOM|UTF-8") do |row|
            process_row(row)
          end
        end

        private

        def process_row(row)
          user_mail = row.fetch("email", nil)
          user_born_at = row.fetch("born_at", nil)
          if mail_valid?(user_mail) && born_at_valid?(user_born_at)
            values << [user_mail, user_born_at]
          else
            errors << row
          end
        end

        def mail_valid?(user_mail)
          user_mail.present? && user_mail.match?(::Devise.email_regexp)
        end

        def born_at_valid?(user_born_at)
          user_born_at.present? # TODO: born_at validation
        end
      end
    end
  end
end
