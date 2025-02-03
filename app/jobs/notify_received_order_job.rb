class NotifyReceivedOrderJob < ApplicationJob
  def perform(order)
    order.group_orders.each do |group_order|
      next unless group_order.ordergroup

      group_order.ordergroup.users.each do |user|
        next unless user.settings.notify['order_received']

        Mailer.deliver_now_with_user_locale user do
          Mailer.order_received(user, group_order)
        end
      end
    end
  end
end
