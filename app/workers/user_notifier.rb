# This plain ruby class should handle all user notifications, called by various models
class UserNotifier
  @queue = :foodsoft_notifier

  # Resque style method to perform every class method defined here
  def self.perform(foodcoop, method_name, *args)
    FoodsoftConfig.select_foodcoop(foodcoop) if FoodsoftConfig[:multi_coop_install]
    self.send method_name, args
  end

  def self.finished_order(args)
    order_id = args.first
    Order.find(order_id).group_orders.each do |group_order|
      next if group_order.ordergroup.nil?

      group_order.ordergroup.users.each do |user|
        if user.settings.notify['order_finished']
          Mailer.deliver_now_with_user_locale user do
            Mailer.order_result(user, group_order)
          end
        end
      end
    end
  end

  def self.received_order(args)
    order_id = args.first
    Order.find(order_id).group_orders.each do |group_order|
      next if group_order.ordergroup.nil?

      group_order.ordergroup.users.each do |user|
        next unless user.settings.notify['order_received']

        Mailer.deliver_now_with_user_locale user do
          Mailer.order_received(user, group_order)
        end
      end
    end
  end

  # If this order group's account balance is made negative by the given/last transaction,
  # a message is sent to all users who have enabled notification.
  def self.negative_balance(args)
    ordergroup_id, transaction_id = args
    transaction = FinancialTransaction.find transaction_id

    Ordergroup.find(ordergroup_id).users.each do |user|
      if user.settings.notify['negative_balance']
        Mailer.deliver_now_with_user_locale user do
          Mailer.negative_balance(user, transaction)
        end
      end
    end
  end
end
