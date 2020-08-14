class SanitizeOrdersSuppliers < ActiveRecord::Migration
  def up
    Order.where(supplier_id: 0).update_all(supplier_id: nil)
  end
end