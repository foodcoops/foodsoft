# This plain ruby class should handle all user notifications, called by various models
class UserNotifier

  def self.finished_order(order_id)
    Order.find(order_id).group_orders.each do |group_order|
      group_order.ordergroup.users.each do |user|
        begin
          Mailer.order_result(user, group_order).deliver if user.settings["notify.orderFinished"] == '1'
        rescue
          Rails.logger.warn "Can't deliver mail to #{user.email}"
        end
      end
    end
  end
end