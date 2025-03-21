class DeltaInput < SimpleForm::Inputs::StringInput
  # for now, need to pass id or it won't work
  def input(wrapper_options)
    options = merge_wrapper_options(input_html_options, wrapper_options)
    options[:type] = 'number'
    options[:step] = 'any'
    options[:data] ||= {}
    options[:data][:delta] ||= 1
    options[:autocomplete] ||= 'off'
    # TODO: get generated id, don't know how yet - `add_default_name_and_id_for_value` might be an option

    template.content_tag :div, class: 'delta-input input-prepend input-append' do
      delta_button(content_tag(:i, nil, class: 'icon icon-minus'), -1, options) +
        delta_button(content_tag(:i, nil, class: 'icon icon-plus'), 1, options) +
        @builder.text_field(attribute_name, options)
    end
  end
  # template.button_tag('−', type: :submit, data: {decrement: options[:id]}, tabindex: -1, class: 'btn') +

  private

  def delta_button(title, direction, options)
    data = { (direction > 0 ? 'increment' : 'decrement') => options[:id] }
    delta = direction * options[:data][:delta]
    template.button_tag(title, type: :button, name: 'delta', value: delta, data: data, tabindex: -1,
                               class: 'btn modify')
  end
end
