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
          user_token = row.fetch("token", nil)
          if mail_valid?(user_mail) && token_valid?(user_token)
            values << [user_mail, user_token]
          else
            errors << row
          end
        end

        def mail_valid?(user_mail)
          user_mail.present? && user_mail.match?(::Devise.email_regexp)
        end

        def token_valid?(user_token)
          user_token.present?
        end
      end
    end
  end
end
