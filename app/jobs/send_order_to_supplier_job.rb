class SendOrderToSupplierJob < ApplicationJob
  def perform(order)
    Mailer.deliver_now_with_default_locale do
      Mailer.order_result_supplier(order.created_by, order)
    end
    order.update!(last_sent_mail: Time.now)
  end
end
