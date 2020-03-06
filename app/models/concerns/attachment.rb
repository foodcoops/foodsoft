module Attachment
  extend ActiveSupport::Concern

  included do
    validate :valid_attachment
    attr_accessor :delete_attachment

    def attachment=(incoming_file)
      self.attachment_data = incoming_file.read
      # allow to soft-fail when FileMagic isn't present and removed from Gemfile (e.g. Heroku)
      self.attachment_mime = defined?(FileMagic) ? FileMagic.new(FileMagic::MAGIC_MIME).buffer(self.attachment_data) : 'application/octet-stream'
    end

    def delete_attachment=(value)
      if ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
        self.attachment_data = nil
        self.attachment_mime = nil
      end
    end

    protected

    def valid_attachment
      if attachment_data
        mime = MIME::Type.simplified(attachment_mime)
        unless %w(application/pdf image/jpeg).include? mime
          errors.add :attachment, I18n.t('model.invalid_mime', mime: mime)
        end
      end
    end
  end
end
