# DateTime picker using bootstrap-datepicker for the time part.
#
# Requires +date_time_attribute+ gem (+workaround) and active on the attribute.
# @see DateTimeAttributeValidate
# @see http://stackoverflow.com/a/20317763/2866660
# @see https://github.com/einzige/date_time_attribute
class DatePickerTimeInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    options = merge_wrapper_options(input_html_options, wrapper_options)
    # Date format must match datepicker's, see app/assets/application.js .
    # And for html5 inputs, match RFC3339, see http://dev.w3.org/html5/markup/datatypes.html#form.data.date .
    # In the future, use html5 date&time inputs. This needs modernizr or equiv. to avoid
    # double widgets, and perhaps conditional css to adjust input width (chrome).
    value = @builder.object.send attribute_name
    date_options = { as: :string, class: 'input-small datepicker' }
    time_options = { as: :string, class: 'input-mini' }
    @builder.input_field("#{attribute_name}_date_value", options.merge(date_options)) + ' ' +
      @builder.input_field("#{attribute_name}_time_value", options.merge(time_options))
    # time_select requires a date_select
    # @builder.time_select("#{attribute_name}_time", {ignore_date: true}, input_html_options.merge(time_options))
  end

  def label_target
    "#{attribute_name}_date_value"
  end
end
