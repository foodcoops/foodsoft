module Finance::InvoicesHelper
  def format_delivery_item delivery
    format_date(delivery.date)
  end
  def format_order_item order
    "#{format_date(order.ends)} (#{number_to_currency(order.sum)})"
  end
end
