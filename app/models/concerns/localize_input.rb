module LocalizeInput
  extend ActiveSupport::Concern

  class_methods do
    def localize_input_of(*attr_names)
      attr_names.flatten.each do |attr|
        define_method "#{attr}=" do |input|
          begin
            if input.is_a? String
              Rails.logger.debug "Input: #{input.inspect}"
              separator = I18n.t("separator", :scope => "number.format")
              delimiter = I18n.t("delimiter", :scope => "number.format")
              input.gsub!(delimiter, "") if input.match(/\d+#{Regexp.escape(delimiter)}+\d+#{Regexp.escape(separator)}+\d+/) # Remove delimiter
              input.gsub!(separator, ".") # Replace separator with db compatible character
            end
            self[attr] = input
          rescue
            Rails.logger.warn "Can't localize input: #{input}"
            self[attr] = input
          end
        end
      end
    end
  end
end
