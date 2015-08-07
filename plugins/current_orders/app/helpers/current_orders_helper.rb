module CurrentOrdersHelper

  def to_pay_message(ordergroup)
    funds = ordergroup.get_available_funds
    if funds > 0
      content_tag :b, I18n.t('helpers.current_orders.pay_done'), style: 'color: green'
    elsif funds == 0
      I18n.t('helpers.current_orders.pay_none')
    else
      content_tag :b, I18n.t('helpers.current_orders.pay_amount', amount: number_to_currency(-ordergroup.get_available_funds))
    end
  end

end
