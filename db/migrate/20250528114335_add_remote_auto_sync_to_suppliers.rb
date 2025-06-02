class AddRemoteAutoSyncToSuppliers < ActiveRecord::Migration[7.0]
  def change
    add_column :suppliers, :remote_auto_sync, :boolean, null: false, default: false
  end
end
