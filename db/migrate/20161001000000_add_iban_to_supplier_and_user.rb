class AddIbanToSupplierAndUser < ActiveRecord::Migration[4.2]
  def change
    add_column :suppliers, :iban, :string
    add_column :users, :iban, :string
  end
end
