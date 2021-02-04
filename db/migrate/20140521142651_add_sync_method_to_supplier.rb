class AddSyncMethodToSupplier < ActiveRecord::Migration[4.2]
  def change
    add_column :suppliers, :shared_sync_method, :string
  end
end
