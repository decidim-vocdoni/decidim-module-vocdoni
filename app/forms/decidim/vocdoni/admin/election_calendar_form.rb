# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class ElectionCalendarForm < Decidim::Form
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :manual_start, Boolean, default: false

        # Election Type attributes
        attribute :auto_start, Boolean, default: true
        attribute :secret_until_the_end, Boolean, default: false
        attribute :interruptible, Boolean, default: true
        attribute :dynamic_census, Boolean, default: false
        attribute :anonymous, Boolean, default: false

        validates :start_time, presence: true, unless: :manual_start?
        validates :end_time, presence: true

        validate :valid_end_time

        def valid_end_time
          errors.add(:start_time, :invalid) if start_time.present? && end_time.present? && start_time >= end_time
          errors.add(:end_time, :invalid) if manual_start? && end_time < Time.zone.now
        end
      end
    end
  end
end
