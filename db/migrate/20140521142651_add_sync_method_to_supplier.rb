class AddSyncMethodToSupplier < ActiveRecord::Migration
  def change
    add_column :suppliers, :shared_sync_method, :string
  end
end
