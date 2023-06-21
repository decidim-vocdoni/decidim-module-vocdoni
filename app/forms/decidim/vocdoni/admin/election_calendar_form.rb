# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      class ElectionCalendarForm < Decidim::Form
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone

        # Election Type attributes
        attribute :auto_start, Boolean, default: true
        attribute :secret_until_the_end, Boolean, default: false
        attribute :interruptible, Boolean, default: true
        attribute :dynamic_census, Boolean, default: false
        attribute :anonymous, Boolean, default: false

        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
      end
    end
  end
end
