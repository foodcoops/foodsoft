class DatePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    options = merge_wrapper_options(input_html_options, wrapper_options)
    @builder.text_field attribute_name, options.merge(class: 'input-small datepicker')
  end
end
