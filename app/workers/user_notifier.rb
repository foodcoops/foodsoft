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
      group_order.ordergroup.users.each do |user|
        begin
          Mailer.order_result(user, group_order).deliver if user.settings.notify["order_finished"]
        rescue
          Rails.logger.warn "Can't deliver mail to #{user.email}"
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
      begin
        Mailer.negative_balance(user, transaction).deliver if user.settings.notify["negative_balance"]
      rescue
        Rails.logger.warn "Can't deliver mail to #{user.email}"
      end
    end
  end
end
