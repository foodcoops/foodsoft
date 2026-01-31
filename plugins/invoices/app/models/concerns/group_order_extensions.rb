# frozen_string_literal: true

module GroupOrderExtensions
  extend ActiveSupport::Concern

  included do
    has_one :group_order_invoice
    # belongs_to :ordergroup_invoice, optional: true
    belongs_to :multi_group_order, optional: true
    belongs_to :multi_order, optional: true
  end
end
