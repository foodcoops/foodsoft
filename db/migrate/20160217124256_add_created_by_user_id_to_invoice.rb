class AddCreatedByUserIdToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :created_by_user_id, :integer
  end
end
