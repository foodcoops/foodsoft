class RenameSupplierRemoteFormatField < ActiveRecord::Migration[7.0]
  change_table :suppliers do |t|
    t.rename :remote_source_format, :remote_data_format
  end
end
