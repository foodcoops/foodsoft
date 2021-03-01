module Admin::ConfigsHelper
  # Returns form input for configuration key.
  #   For configuration keys that contain a {Hash}, {ActiveView::Helpers::FormBuilder#fields_for fields_for} can be used.
  #   When the key is not {FoodsoftConfig#allowed_key? allowed}, +nil+ is returned.
  # @param form [ActionView::Helpers::FormBuilder] Form object.
  # @param key [Symbol, String] Configuration key.
  # @param options [Hash] Options passed to the form builder.
  # @option options [Boolean] :required Wether field is shown as required (default not).
  # @option options [Array<IceCube::Rule>] :rules Rules for +as: :recurring_select+
  # @return [String] Form input for configuration key.
  # @todo find way to pass current value to time_zone input without using default
  def config_input(form, key, options = {}, &block)
    return unless @cfg.allowed_key? key

    options[:label] ||= config_input_label(form, key)
    options[:required] ||= false
    options[:input_html] ||= {}
    config_input_field_options form, key, options[:input_html]
    config_input_tooltip_options form, key, options[:input_html]
    if options[:as] == :boolean
      options[:input_html][:checked] = 'checked' if v = options[:input_html].delete(:value) && v != 'false'
      options[:checked_value] = 'true' if options[:checked_value].nil?
      options[:unchecked_value] = 'false' if options[:unchecked_value].nil?
    elsif options[:collection] || options[:as] == :select
      options[:selected] = options[:input_html].delete(:value)
      return form.input key, options, &block
    elsif options[:as] == :time_zone
      options[:default] = options[:input_html].delete(:value)
      return form.input key, options, &block
    end
    block ||= proc { config_input_field form, key, options.merge(options[:input_html]) } if options[:as] == :select_recurring
    form.input key, options, &block
  end

  # @return [String] Label name in form for configuration key.
  # @param form [ActionView::Helpers::FormBuilder] Form object.
  # @param key [Symbol, String] Configuration key.
  # @see #config_input
  def config_input_label(form, key)
    cfg_path = form.lookup_model_names[1..-1] + [key]
    I18n.t("config.keys.#{cfg_path.map(&:to_s).join('.')}")
  end

  # @return [String] Form input field for configuration key.
  # @see config_input
  # @option options [String] :checked_value Value for boolean when checked (default +true+)
  # @option options [String] :unchecked_value Value for boolean when not checked (default +false+)
  # @todo find out how to pass +checked_value+ and +unchecked_value+ to +input_field+
  def config_input_field(form, key, options = {})
    return unless @cfg.allowed_key? :key

    options[:required] ||= false
    config_input_field_options form, key, options
    config_input_tooltip_options form, key, options
    if options[:as] == :boolean
      checked_value = options.delete(:checked_value) || 'true'
      unchecked_value = options.delete(:unchecked_value) || 'false'
      options[:checked] = 'checked' if v = options.delete(:value) && v != 'false'
      # different key for hidden field so that allow clocking on label focuses the control
      form.hidden_field(key, id: "#{key}_", value: unchecked_value, as: :hidden) + form.check_box(key, options, checked_value, false)
    elsif options[:as] == :select_recurring
      options[:value] = FoodsoftDateUtil.rule_from(options[:value])
      options[:rules] ||= []
      options[:rules].unshift options[:value] unless options[:value].blank?
      options[:rules].push [I18n.t('recurring_select.not_recurring'), '{}'] if options.delete(:allow_blank) # blank after current value
      form.select_recurring key, options.delete(:rules).uniq, options
    else
      form.input_field key, options
    end
  end

  # @return [String] Form heading with checkbox with block passed in expandable +fieldset+.
  # @param form [ActionView::Helpers::FormBuilder] Form object.
  # @param key [Symbol, String] Configuration key of a boolean (e.g. +use_messages+).
  # @option options [String] :label Label to show
  def config_use_heading(form, key, options = {})
    head = content_tag :label do
      lbl = options[:label] || config_input_label(form, key)
      field = config_input_field(form, key, as: :boolean, boolean_style: :inline,
                                            data: { toggle: 'collapse', target: "##{key}-fields" })
      content_tag :h4 do
        # put in span to keep space for tooltip at right
        content_tag :span, (lbl + field).html_safe, config_input_tooltip_options(form, key, {})
      end
    end
    fields = content_tag(:fieldset, id: "#{key}-fields", class: "collapse#{' in' if @cfg[key]}") do
      yield
    end
    head + fields
  end

  # Returns configuration value suitable for rendering in HTML.
  #   Makes keys different from +app_config.yml+ configuration bold,
  #   protects sensitive values like keys and passwords, and makes
  #   links from URLs.
  # @param key [String] Configuration key
  # @param value [String] Configuration value
  # @return [String] Configuration value suitable for rendering in HTML.
  def show_config_value(key, value)
    if key =~ /passw|secr|key/
      '(protected)'
    elsif value.is_a? Hash
      content_tag :ul do
        value.map do |k, v|
          content_tag :li, content_tag(:tt, "#{k}: ") + show_config_value(k, v).to_s
        end.join.html_safe
      end
    elsif value.is_a? Enumerable
      content_tag :ul, value.map { |v| content_tag :li, h(v) }.join.html_safe
    elsif key =~ /url|website|www|homepage/
      link_to(value, value.to_s).html_safe
    else
      value
    end
  end

  # @return [String] Tooltip element (span)
  # @param form [ActionView::Helpers::FormBuilder] Form object.
  # @param key [Symbol, String] Configuration key of a boolean (e.g. +use_messages+).
  def config_tooltip(form, key, options = {}, &block)
    content_tag :span, config_input_tooltip_options(form, key, options), &block
  end

  private

  def config_input_tooltip_options(form, key, options)
    # tooltip with help info to the right
    cfg_path = form.lookup_model_names[1..-1] + [key]
    tooltip = I18n.t("config.hints.#{cfg_path.map(&:to_s).join('.')}", default: '')
    unless tooltip.blank?
      options[:data] ||= {}
      options[:data][:toggle] ||= 'tooltip'
      options[:data][:placement] ||= 'right'
      options[:title] ||= tooltip
    end
    options
  end

  def config_input_field_options(form, key, options)
    cfg_path = form.lookup_model_names[1..-1] + [key]
    # set current value
    unless options.has_key?(:value)
      value = @cfg
      cfg_path.each { |n| value = value[n] if value.respond_to? :[] }
      options[:value] = value
    end
    options
  end
end
