module Attachment
  extend ActiveSupport::Concern

  included do
    validate :valid_attachments
    attr_accessor :delete_attachment

    # def delete_attachment
    def delete_attachment=(value)
      if ActiveModel::Type::Boolean.new.cast(value)
        attachment = ActiveStorage::Attachment.find(params[:attachment_id])
        attachment.purge_later
        respond_to do |format|
          format.js
        end
      end
    end

    protected

    def valid_attachments
      attachments.each do |attachment|
        errors.add(:attachments, I18n.t('model.invoice.invalid_mime', mime: attachment.content_type)) unless attachment.content_type.in?(%w[image/jpeg image/png application/pdf])
      end
    end

  end
end
