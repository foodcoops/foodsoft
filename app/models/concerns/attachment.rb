# Shared attachment handling for models that use Active Storage attachments
# (currently `Invoice` and `User`).
module Attachment
  extend ActiveSupport::Concern

  included do
    validate :valid_attachments
  end

  # validates that the attachments are jpeg, png or pdf
  protected

  def valid_attachments
    attachments.each do |attachment|
      errors.add(:attachments, I18n.t("model.#{model_name.i18n_key}.invalid_mime", mime: attachment.content_type)) unless attachment.content_type.in?(%w[image/jpeg image/png application/pdf])
    end
  end
end
