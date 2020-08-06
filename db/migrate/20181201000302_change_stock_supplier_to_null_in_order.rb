class ChangeStockSupplierToNullInOrder < ActiveRecord::Migration[4.2]
  class Order < ActiveRecord::Base; end

  def up
    Order.where(supplier_id: 0).update_all(supplier_id: nil)
  end

  def down
    Order.where(supplier_id: nil).update_all(supplier_id: 0)
  end
end
