class ClearInvalidInvoicesFromOrders < ActiveRecord::Migration
  class Order < ActiveRecord::Base; end
  class Invoice < ActiveRecord::Base; end

  def up
    Order.where.not(invoice_id: Invoice.all).update_all(invoice_id: nil)
  end
end
