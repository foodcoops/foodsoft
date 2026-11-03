class MultiGroupOrder < ApplicationRecord
  belongs_to :multi_order, optional: false
  has_many :group_orders, dependent: :nullify
  has_one :ordergroup_invoice, dependent: :destroy

  validate :consistent_financial_transaction_type

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

  def financial_transaction
    group_orders.first&.financial_transaction
  end

  private

  # payment_method of the OrdergroupInvoice is derived from the financial
  # transaction type of the group orders, so they must not disagree
  def consistent_financial_transaction_type
    type_ids = group_orders.filter_map { |go| go.financial_transaction&.financial_transaction_type_id }.uniq
    return if type_ids.size < 2

    errors.add(:base, I18n.t('multi_group_orders.inconsistent_financial_transaction_type', ordergroup: ordergroup&.name || '?'))
  end
end
