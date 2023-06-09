# workaround for https://github.com/einzige/date_time_attribute/issues/14
require 'date_time_attribute'

module DateTimeAttributeValidate
  extend ActiveSupport::Concern
  include DateTimeAttribute

  module ClassMethods
    def date_time_attribute(*attributes)
      super

      attributes.each do |attribute|
        validate -> { send("#{attribute}_datetime_value_valid") }

        # allow resetting the field to nil
        before_validation do
          if instance_variable_get("@#{attribute}_is_set")
            date = instance_variable_get("@#{attribute}_date_value")
            time = instance_variable_get("@#{attribute}_time_value")
            send("#{attribute}=", nil) if date.blank? && time.blank?
          end
        end

        # remember old date and time values
        define_method("#{attribute}_date_value=") do |val|
          instance_variable_set("@#{attribute}_is_set", true)
          instance_variable_set("@#{attribute}_date_value", val)
          begin
            send("#{attribute}_date=", val)
          rescue StandardError
            nil
          end
        end
        define_method("#{attribute}_time_value=") do |val|
          instance_variable_set("@#{attribute}_is_set", true)
          instance_variable_set("@#{attribute}_time_value", val)
          begin
            send("#{attribute}_time=", val)
          rescue StandardError
            nil
          end
        end

        # fallback to field when values are not set
        define_method("#{attribute}_date_value") do
          instance_variable_get("@#{attribute}_date_value") || send("#{attribute}_date").try do |e|
            e.strftime('%Y-%m-%d')
          end
        end
        define_method("#{attribute}_time_value") do
          instance_variable_get("@#{attribute}_time_value") || send("#{attribute}_time").try do |e|
            e.strftime('%H:%M')
          end
        end

        private

        # validate date and time
        define_method("#{attribute}_datetime_value_valid") do
          date = instance_variable_get("@#{attribute}_date_value")
          unless date.blank? || begin
            Date.parse(date)
          rescue StandardError
            nil
          end
            errors.add(attribute, 'is not a valid date') # @todo I18n
          end
          time = instance_variable_get("@#{attribute}_time_value")
          unless time.blank? || begin
            Time.parse(time)
          rescue StandardError
            nil
          end
            errors.add(attribute, 'is not a valid time') # @todo I18n
          end
        end
      end
    end
  end
end
