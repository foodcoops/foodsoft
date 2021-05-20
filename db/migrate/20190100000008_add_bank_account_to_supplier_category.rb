class AddBankAccountToSupplierCategory < ActiveRecord::Migration[4.2]
  def change
    add_reference :supplier_categories, :bank_account
  end
end
