class AddSupplierPriceToArticles < ActiveRecord::Migration
  def change
    unless column_exists? :articles, :supplier_price
      add_column :articles, :supplier_price, :decimal, precision: 8, scale: 2
    end
  end
end
