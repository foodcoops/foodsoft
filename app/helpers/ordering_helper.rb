module OrderingHelper
  def data_to_js(ordering_data)
    ordering_data[:order_articles].map { |id, data|
      [id, data[:price], data[:unit], data[:total_price], data[:others_quantity], data[:others_tolerance], data[:used_quantity], data[:quantity_available]]
    }.map { |row|
      "addData(#{row.join(', ')});"
    }.join("\n")
  end

  def link_to_ordering(order, options = {})
    path = if group_order = order.group_order(current_user.ordergroup)
             edit_group_order_path(group_order, :order_id => order.id)
           else
             new_group_order_path(:order_id => order.id)
           end
    link_to order.name, path, options
  end

  # Return css class names for order result table

  def order_article_class_name(quantity, tolerance, result)
    if (quantity + tolerance > 0)
      result > 0 ? 'success' : 'failed'
    else
      'ignored'
    end
  end
end