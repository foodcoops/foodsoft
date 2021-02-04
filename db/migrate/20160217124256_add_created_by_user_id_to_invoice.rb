class AddCreatedByUserIdToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :created_by_user_id, :integer
  end
end
