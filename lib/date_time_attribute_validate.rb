# workaround for https://github.com/einzige/date_time_attribute/issues/14
require 'date_time_attribute'

module DateTimeAttributeValidate
  extend ActiveSupport::Concern
  include DateTimeAttribute

  module ClassMethods
    def date_time_attribute(*attributes)
      super

      attributes.each do |attribute|
        validate -> { self.send("#{attribute}_datetime_value_valid") }

        # allow resetting the field to nil
        before_validation do
          if self.instance_variable_get("@#{attribute}_is_set")
            date = self.instance_variable_get("@#{attribute}_date_value")
            time = self.instance_variable_get("@#{attribute}_time_value")
            if date.blank? && time.blank?
              self.send("#{attribute}=", nil)
            end
          end
        end

        # remember old date and time values
        define_method("#{attribute}_date_value=") do |val|
          self.instance_variable_set("@#{attribute}_is_set", true)
          self.instance_variable_set("@#{attribute}_date_value", val)
          self.send("#{attribute}_date=", val) rescue nil
        end
        define_method("#{attribute}_time_value=") do |val|
          self.instance_variable_set("@#{attribute}_is_set", true)
          self.instance_variable_set("@#{attribute}_time_value", val)
          self.send("#{attribute}_time=", val) rescue nil
        end

        # fallback to field when values are not set
        define_method("#{attribute}_date_value") do
          self.instance_variable_get("@#{attribute}_date_value") || self.send("#{attribute}_date").try { |e| e.strftime('%Y-%m-%d') }
        end
        define_method("#{attribute}_time_value") do
          self.instance_variable_get("@#{attribute}_time_value") || self.send("#{attribute}_time").try { |e| e.strftime('%H:%M') }
        end

        private

        # validate date and time
        define_method("#{attribute}_datetime_value_valid") do
          date = self.instance_variable_get("@#{attribute}_date_value")
          unless date.blank? || (Date.parse(date) rescue nil)
            errors.add(attribute, "is not a valid date") # @todo I18n
          end
          time = self.instance_variable_get("@#{attribute}_time_value")
          unless time.blank? || (Time.parse(time) rescue nil)
            errors.add(attribute, "is not a valid time") # @todo I18n
          end
        end
      end
    end
  end
end
