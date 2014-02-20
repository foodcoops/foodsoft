# ClientSideValidations Initializer

# DISABLED FOR RAILS4
# Uncomment to disable uniqueness validator, possible security issue
#  Disabled because of possible security issue and because of bug
#  https://github.com/bcardarella/client_side_validations/pull/532
#ClientSideValidations::Config.disabled_validators = [:uniqueness]

# Uncomment to validate number format with current I18n locale
#  Foodsoft is currently using localize_input which is activated on certain
#  fields only, meaning we can't globally turn this on. The non-i18n number
#  format is still supported - so for now keep false.
# ClientSideValidations::Config.number_format_with_locale = true

# Uncomment the following block if you want each input field to have the validation messages attached.
# ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
#   unless html_tag =~ /^<label/
#     %{<div class="field_with_errors">#{html_tag}<label for="#{instance.send(:tag_id)}" class="message">#{instance.error_message.first}</label></div>}.html_safe
#   else
#     %{<div class="field_with_errors">#{html_tag}</div>}.html_safe
#   end
# end

