class DatePickerInput < SimpleForm::Inputs::StringInput
  def input
    @builder.text_field(attribute_name, input_html_options.merge({class: 'datepicker'}))
  end
end
