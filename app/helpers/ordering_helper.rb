module OrderingHelper
  def data_to_js(ordering_data)
    ordering_data[:order_articles].map do |id, data|
      if Foodsoft.config[:tolerance_is_costly]
        [id, data[:price], data[:unit], data[:price] * (data[:tolerance] + data[:quantity]), data[:others_quantity], data[:others_tolerance], data[:used_quantity], 0]
      else
        [id, data[:price], data[:unit], data[:price] * data[:quantity], data[:others_quantity], data[:others_tolerance], data[:used_quantity], 0]
      end
    end
  end

  def link_to_ordering(order)
    path = if group_order = order.group_order(current_user.ordergroup)
             edit_group_order_path(group_order, :order_id => order.id)
           else
             new_group_order_path(:order_id => order.id)
           end
    link_to order.name, path
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