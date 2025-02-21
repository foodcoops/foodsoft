class AlterSuppliersSharingFields < ActiveRecord::Migration[5.2]
  def up
    change_table :suppliers do |t|
      t.remove :shared_supplier_id
      t.column :supplier_remote_source, :string
      t.column :external_uuid, :string
    end

    add_index :suppliers, :external_uuid, unique: true
  end

  def down
    change_table :suppliers do |t|
      t.column :shared_supplier_id, :integer
      t.remove :supplier_remote_source
      t.remove :external_uuid
    end
  end
end
