module GroupOrdersHelper
  def data_to_js(ordering_data)
    ordering_data[:order_articles].map do |id, data|
      [id, data[:price], data[:unit], data[:total_price], data[:others_quantity], data[:others_tolerance],
       data[:used_quantity], data[:quantity_available]]
    end.map do |row|
      "addData(#{row.join(', ')});"
    end.join("\n")
  end

  # Returns a link to the page where a group_order can be edited.
  # If the option :show is true, the link is for showing the group_order.
  def link_to_ordering(order, options = {}, &block)
    group_order = order.group_order(current_user.ordergroup)
    path = if options[:show] && group_order
             group_order_path(group_order)
           elsif group_order
             edit_group_order_path(group_order, order_id: order.id)
           else
             new_group_order_path(order_id: order.id)
           end
    options.delete(:show)
    name = block_given? ? capture(&block) : order.name
    path ? link_to(name, path, options) : name
  end

  # Return css class names for order result table

  def order_article_class_name(quantity, tolerance, result)
    if quantity + tolerance > 0
      result > 0 ? 'success' : 'failed'
    else
      'ignored'
    end
  end

  def get_order_results(order_article, group_order_id)
    goa = order_article.group_order_articles.detect { |goa| goa.group_order_id == group_order_id }
    quantity, tolerance, result, sub_total = if goa.present?
                                               [goa.quantity, goa.tolerance, goa.result, goa.total_price(order_article)]
                                             else
                                               [0, 0, 0, 0]
                                             end

    { group_order_article: goa, quantity: quantity, tolerance: tolerance, result: result, sub_total: sub_total }
  end

  def get_missing_units_css_class(quantity_missing, article_version)
    if quantity_missing == 0
      ''
    elsif quantity_missing <= article_version.group_order_granularity
      'missing-few'
    else
      'missing-many'
    end
  end
end
