module LocalizeInput
  extend ActiveSupport::Concern

  def self.parse(input)
    return input unless input.is_a? String

    Rails.logger.debug { "Input: #{input.inspect}" }
    separator = I18n.t("separator", scope: "number.format")
    delimiter = I18n.t("delimiter", scope: "number.format")
    input.gsub!(delimiter, "") if input.match(/\d+#{Regexp.escape(delimiter)}+\d+#{Regexp.escape(separator)}+\d+/) # Remove delimiter
    input.gsub!(separator, ".") # Replace separator with db compatible character
    input
  rescue
    Rails.logger.warn "Can't localize input: #{input}"
    input
  end

  class_methods do
    def localize_input_of(*attr_names)
      attr_names.flatten.each do |attr|
        define_method "#{attr}=" do |input|
          self[attr] = LocalizeInput.parse(input)
        end
      end
    end
  end
end
