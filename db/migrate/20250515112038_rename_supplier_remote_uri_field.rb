class RenameSupplierRemoteUriField < ActiveRecord::Migration[7.0]
  change_table :suppliers do |t|
    t.rename :supplier_remote_source, :remote_location_uri
  end
end
