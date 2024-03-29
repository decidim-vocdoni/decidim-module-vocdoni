# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This class holds a Form to create/update elections from Decidim's admin panel.
      class ElectionForm < Decidim::Form
        include TranslatableAttributes
        include AttachmentAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :stream_uri, String
        attribute :attachment, AttachmentForm

        attachments_attribute :photos

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validate :notify_missing_attachment_if_errored

        private

        # This method will add an error to the `photos` field only if there's
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
          errors.add(:add_photos, :needs_to_be_reattached) if errors.any? && add_photos.present?
        end
      end
    end
  end
end
