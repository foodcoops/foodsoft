class MultiGroupOrder < ApplicationRecord
  belongs_to :multi_order, optional: false
  has_many :group_orders, dependent: :nullify
  has_one :ordergroup_invoice, dependent: :destroy

  def ordergroup
    group_orders.first&.ordergroup
  end

  def price
    group_orders.map(&:price).sum
  end

  def group_order_invoice
    ordergroup_invoice
  end

  def order
    multi_order
  end
end
