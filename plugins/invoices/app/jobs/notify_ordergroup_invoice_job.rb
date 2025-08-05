class NotifyOrdergroupInvoiceJob < ApplicationJob
  def perform(ordergroup_invoice)
    ordergroup = ordergroup_invoice.multi_group_order.ordergroup
    ordergroup.users.each do |user|
      ordergroup_invoice.update!(email_sent_at: Time.current)
      InvoiceMailer.deliver_now_with_user_locale user do
        InvoiceMailer.ordergroup_invoice(ordergroup_invoice, user)
      end
    end
  end
end
