# This plain ruby class should handle all user notifications, called by various models
class UserNotifier
  @queue = :foodsoft_notifier

  # this enqueues a notification but also removes any duplicates
  # eg, if enqueue_in is called several times within the first delay,
  # it will only execute the notification once
  def self.enqueue_in(delay, *args)
    # ignore delays in development
    puts "enqueue_in: Rails.env=#{Rails.env}"
    if (Rails.env == 'development')
      puts "enqueue_in: ignoring delay of #{delay} seconds : #{args}"
      delay = 1
    else
      puts "enqueue_in delay of #{delay} seconds : #{args}"
    end
    args = args.unshift(FoodsoftConfig.scope)
    Resque.remove_delayed(UserNotifier, *args)
    Resque.enqueue_in(delay, UserNotifier, *args)
  end


  # Resque style method to perform every class method defined here
  def self.perform(foodcoop, method_name, *args)
    puts ("Performing action  #{method_name} with args #{args.as_json} on foodcoop #{foodcoop}")
    FoodsoftConfig.select_foodcoop(foodcoop) if FoodsoftConfig[:multi_coop_install]
    self.send method_name, args
  end

  def self.queue_order_updated_email(delay:, group_order_id:, message:)
    UserNotifier.enqueue_in(delay,
                            'email_updated_group_order',
                            group_order_id, message,)
  end


  # when the order has been 'closed'
  def self.finished_order(args)
    # just delegate, one email template for all
    UserNotifier.email_updated_orders(args.push('The order has been closed and sent to supplier.'))
  end

  # when the order has been settled
  def self.closed_order(args)
    # just delegate, one email template for all
    UserNotifier.email_updated_orders(args.push('Here are your final order charges.'))
  end

  # when the order has been updated
  def self.updated_order(args)
    # just delegate, one email template for all
    UserNotifier.email_updated_orders(args.push('There were updates to your order, please review any changes.'))
  end

  # any time the order changes we send an email to members
  def self.email_updated_orders(args)
    puts "email_updated_orders #{args.as_json}"
    order_id, message = args.first(2)
    Order.find(order_id).group_orders.each do |group_order|
      next if group_order.ordergroup.nil?
      puts "emailing #{group_order.ordergroup.users.count} users"
      group_order.ordergroup.users.each do |user|
        # if user.settings.notify['order_finished']

        begin
          puts "email_updated_orders emailing user #{user.email}"


        Mailer.deliver_now_with_user_locale user do
          Mailer.order_result(user, group_order, message)
        end
        rescue Mailer::MailCancelled => e
          puts "mail was canceled/no mail required #{e}"
        rescue  => e
          puts "email_updated_orders - problem occurred #{e} #{e.backtrace}"
        end
      end
    end
  end

  # # any time the order changes we send an email to members
  # def self.email_updated_order(args)
  #   puts "email_updated_order #{args.as_json}"
  #   order_id, ordergroup_id, message = args.first(3)
  #   group_order = Order.find(order_id).group_orders.where(ordergroup_id: ordergroup_id).first
  #   email_updated_group_order(group_order.id, message)
  # end

  def self.email_updated_group_order(args)
    group_order_id, message = args
    puts "email_updated_group_order #{[group_order_id, message]}.as_json}"
    group_order = GroupOrder.find(group_order_id)
    if group_order.ordergroup
      group_order.ordergroup.users.each do |user|
        # if user.settings.notify['order_finished'] || true
        begin
        puts "email_updated_group_order emailing user #{user.email}"

        Mailer.deliver_now_with_user_locale user do
          Mailer.order_result(user, group_order, message)
        end
        rescue Mailer::MailCancelled => e
          puts "mail was canceled/no mail required #{e}"
        rescue  => e
          puts "email_updated_group_order: problem occurred #{e}"
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

  protected


end
