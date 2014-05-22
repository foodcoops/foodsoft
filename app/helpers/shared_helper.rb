module SharedHelper

  # provide input_html for password autocompletion
  def autocomplete_flag_to_password_html(password_autocomplete)
    case password_autocomplete
      when true then {autocomplete: 'on'}
      when false then {autocomplete: 'off'}
      when 'store-only' then {autocomplete: 'off', data: {store: 'on'}}
      else {}
    end
  end

  def show_price_markup(id, options = {})
    list = FoodsoftConfig[:price_markup_list] or return
    id = id.price_markup_key if id.is_a? Ordergroup
    return if options[:optional] and id == FoodsoftConfig[:price_markup]

    pct = number_to_percentage(list[id]['markup'])
    case options[:format].to_sym
    when :percent
      pct
    when :percent_label
      "#{heading_helper Ordergroup, :price_markup_key} #{pct}"
    when nil
    when :full
      "#{list[id]['name'] or id} (#{pct})"
    when :full_label
      "#{list[id]['name'] or id} (#{heading_helper Ordergroup, :price_markup_key} #{pct})"
    when :icon
      content_tag(:i, nil, class: 'icon-asterisk price_markup_note', title: show_price_markup(id, format: :full_label))
    when :label
      list[id]['name'] or id
    when :member
      show_price_markup id, options.merge({format: FoodsoftConfig[:price_markup_member_format] || 'full'})
    end
  end

end
