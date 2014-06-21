module Admin::ConfigsHelper
  # Returns form input for configuration key.
  #   For configuration keys that contain a {Hash}, {ActiveView::Helpers::FormBuilder#fields_for fields_for} can be used.
  #   When the key is not {FoodsoftConfig#allowed_key? allowed}, +nil+ is returned.
  # @param form [ActionView::Helpers::FormBuilder] Form object.
  # @param key [Symbol, String] Configuration key.
  # @param options [Hash] Options passed to the form builder.
  # @option options [Boolean] :required Wether field is shown as required (default not).
  # @return [String] Form input for configuration key.
  def config_input(form, key, options = {}, &block)
    return unless @cfg.allowed_key? key
    options[:label] = config_input_label(form, key)
    options[:required] ||= false
    options[:input_html] ||= {}
    config_input_field_options form, key, options[:input_html]
    config_input_tooltip_options form, key, options[:input_html]
    if options[:as] == :boolean
      options[:input_html][:checked] = 'checked' if options[:input_html].delete(:value)
      options[:checked_value] = true
      options[:unchecked_value] = false
    elsif options[:collection] or options[:as] == :select
      options[:selected] = options[:input_html].delete(:value)
      return form.input key, options, &block
    end
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
  # @todo find out how to pass +checked_value+ and +unchecked_value+ to +input_field+
  def config_input_field(form, key, options = {})
    return unless @cfg.allowed_key? :key
    config_input_field_options form, key, options
    config_input_tooltip_options form, key, options
    if options[:as] == :boolean
      options[:checked] = 'checked' if options.delete(:value)
      form.hidden_field(key, value: false, as: :hidden) + form.check_box(key, options, true, false)
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
                                data: {toggle: 'collapse', target: "##{key}-fields"}) 
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
        value.map do |k,v|
          content_tag :li, content_tag(:tt, "#{k}: ") + show_config_value(k, v).to_s
        end.join.html_safe
      end
    elsif value.is_a? Enumerable
      content_tag :ul, value.map {|v| content_tag :li, h(v)}.join.html_safe
    elsif key =~ /url|website|www|homepage/
      link_to(value, value).html_safe
    else
      value
    end
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
    value = @cfg
    cfg_path.each {|n| value = value[n] unless value.nil? }
    options[:value] ||= value
    options
  end
end
