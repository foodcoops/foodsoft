class IntroduceReceivedStateInOrders < ActiveRecord::Migration[5.2]
  def up
    Order.where(state: 'finished').each do |order|
      order.update_attribute(:state, 'received') if order.order_articles.where.not(units_received: nil).any?
    end
  end

  def down
    Order.where(state: 'received').update_all(state: 'finished')
  end
end
