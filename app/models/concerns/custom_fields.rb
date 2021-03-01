module CustomFields
  extend ActiveSupport::Concern
  include RailsSettings::Extend

  attr_accessor :custom_fields

  included do
    after_initialize do
      settings.defaults['custom_fields'] = {} unless settings.custom_fields
    end

    after_save do
      self.settings.custom_fields = custom_fields if custom_fields
    end
  end
end
