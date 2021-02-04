class AddRoleInvoicesToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :role_invoices, :boolean, :default => false, :null => false
  end
end
