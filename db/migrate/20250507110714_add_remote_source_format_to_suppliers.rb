class AddRemoteSourceFormatToSuppliers < ActiveRecord::Migration[7.0]
  def change
    add_column :suppliers, :remote_source_format, :string
  end
end
