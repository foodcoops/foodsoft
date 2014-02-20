# DateTime picker using bootstrap-datepicker for the time part
# requires `date_time_attribute` gem and active on the attribute
#   http://stackoverflow.com/a/20317763/2866660
#   https://github.com/einzige/date_time_attribute
class DatePickerTimeInput < SimpleForm::Inputs::StringInput
  def input
    # Date format must match datepicker's, see app/assets/application.js .
    # And for html5 inputs, match RFC3339, see http://dev.w3.org/html5/markup/datatypes.html#form.data.date .
    # In the future, use html5 date&time inputs. This needs modernizr or equiv. to avoid
    # double widgets, and perhaps conditional css to adjust input width (chrome).
    value = @builder.object.send attribute_name
    date_options = {as: :string, class: 'input-small datepicker', value: value.try {|e| e.strftime('%Y-%m-%d')}}
    time_options = {as: :string, class: 'input-mini', value: value.try {|e| e.strftime('%H:%M')}}
    @builder.input_field("#{attribute_name}_date", input_html_options.merge(date_options)) + ' ' +
    @builder.input_field("#{attribute_name}_time", input_html_options.merge(time_options))
    # time_select requires a date_select
    #@builder.time_select("#{attribute_name}_time", {ignore_date: true}, input_html_options.merge(time_options))
  end
end
