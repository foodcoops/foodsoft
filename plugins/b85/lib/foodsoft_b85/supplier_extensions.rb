module FoodsoftB85
  module SupplierExtensions
    extend ActiveSupport::Concern

    included do
      validates :customer_number, length: { in: 1..6 }, numericality: { only_integer: true }, if: -> { remote_order_method == :ftp_b85 }
      validates :remote_order_url, presence: true, if: -> { remote_order_method == :ftp_b85 }
      validate :no_open_orders, if: -> { remote_order_method == :ftp_b85 && remote_order_method_changed? }
    end

    def no_open_orders
      errors.add :remote_order_method, :no_open_orders if orders.open.exists?
    end
  end
end
