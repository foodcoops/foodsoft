class AddRemoteOrderMethodToSupplier < ActiveRecord::Migration[7.0]
  def change
    add_column :suppliers, :remote_order_method, :string, null: false, default: 'email'
  end
end
