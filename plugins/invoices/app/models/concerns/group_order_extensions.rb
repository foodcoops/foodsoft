# frozen_string_literal: true

module GroupOrderExtensions
  extend ActiveSupport::Concern

  included do
    has_one :group_order_invoice
  end
end
