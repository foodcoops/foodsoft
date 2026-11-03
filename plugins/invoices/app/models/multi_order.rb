class MultiOrder < ApplicationRecord
  has_many :orders, dependent: :nullify
  has_many :order_articles, through: :orders
  has_many :multi_group_orders, dependent: :destroy

  # TODO: diese association lösen
  has_many :group_orders, through: :multi_group_orders
  # has_many :ordergroups, through: :group_orders
  has_many :ordergroup_invoices, through: :multi_group_orders

  validate :check_orders
  after_create :create_multi_group_orders

  def name
    orders.map(&:name).join(', ')
  end

  def closed?
    orders.all?(&:closed?)
  end

  def stockit?
    orders.all?(&:stockit?)
  end

  def updated_by
    orders.map(&:updated_by).compact.first
  end

  def updated_at
    orders.map(&:updated_at).compact.first
  end

  def foodcoop_result
    orders.map(&:foodcoop_result).compact_blank.sum
  end

  def supplier
    # TODO: who is this?
    orders.map(&:supplier).compact.first
  end

  private

  def check_orders
    if orders.blank?
      errors.add(:base, 'No orders selected')
      return
    end
    orders.each do |order|
      errors.add(:base, "Order #{order.name} has no group orders") if order.group_orders.blank?
      errors.add(:base, "Order #{order.name} is not closed") unless order.closed?
      errors.add(:base, "Order #{order.name} has group order invoices") if order.group_orders.any? { |go| go.group_order_invoice.present? }
    end
  end

  def create_multi_group_orders
    return if orders.empty?

    all_group_orders = orders.flat_map(&:group_orders)
    grouped_by_ordergroup = all_group_orders.group_by(&:ordergroup_id)

    grouped_by_ordergroup.each_value do |group_orders|
      multi_group_order = MultiGroupOrder.create!(
        multi_order: self, group_orders: group_orders
      )
      # Now, associate each group_order with the new multi_group_order
      group_orders.each do |group_order|
        group_order.update!(multi_group_order: multi_group_order)
      end
    end
  end
end
