class NotifyGroupOrderInvoiceJob < ApplicationJob
  def perform(group_order_invoice)
    ordergroup = group_order_invoice.group_order.ordergroup
    ordergroup.users.each do |user|
      Mailer.deliver_now_with_user_locale user do
        Mailer.group_order_invoice(group_order_invoice, user)
      end
    end
  end
end
