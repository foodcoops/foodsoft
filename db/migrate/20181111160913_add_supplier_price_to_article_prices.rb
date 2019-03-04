class AddSupplierPriceToArticlePrices < ActiveRecord::Migration
  def change
    unless column_exists? :article_prices, :supplier_price
        add_column :article_prices, :supplier_price, :decimal, precision: 8, scale: 2
    end

  end
end
