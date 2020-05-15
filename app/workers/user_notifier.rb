# This plain ruby class should handle all user notifications, called by various models
class UserNotifier
  @queue = :foodsoft_notifier

  # this enqueues a notification but also removes any duplicates
  # eg, if enqueue_in is called several times within the first delay,
  # it will only execute the notification once
  def self.enqueue_in(delay, *args)
    # args = args.unshift UserNotifier
    Resque.remove_delayed(UserNotifier, *args)
    Resque.enqueue_in(delay, UserNotifier, *args)
  end


  # Resque style method to perform every class method defined here
  def self.perform(foodcoop, method_name, *args)
    FoodsoftConfig.select_foodcoop(foodcoop) if FoodsoftConfig[:multi_coop_install]
    self.send method_name, args
  end

  # when the order has been 'closed'
  def self.finished_order(args)
    # just delegate, one email template for all
    UserNotifier.email_updated_order(args.push('Order has been closed and sent to supplier.'))
  end

  # when the order has been settled
  def self.closed_order(args)
    # just delegate, one email template for all
    UserNotifier.email_updated_order(args.push('Here are your final order charges.'))
  end

  # when the order has been updated
  def self.closed_order(args)
    # just delegate, one email template for all
    UserNotifier.email_updated_order(args.push('The order has been updated, please review any changes.'))
  end

  # any time the order changes we send an email to members
  def self.email_updated_order(args)
    order_id, message = args.first(2)
    Order.find(order_id).group_orders.each do |group_order|
      next if group_order.ordergroup.nil?
      group_order.ordergroup.users.each do |user|
        # if user.settings.notify['order_finished'] || true
          Mailer.deliver_now_with_user_locale user do
            Mailer.order_result(user, group_order, message)
          end
        # end
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
