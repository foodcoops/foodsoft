class AddRoleInvoicesToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :role_invoices, :boolean, :default => false, :null => false
  end
end
