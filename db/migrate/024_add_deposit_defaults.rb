class AddDepositDefaults < ActiveRecord::Migration[4.2]
  def self.up
    change_column_default :articles, :deposit, 0.0
    change_column_default :order_article_results, :net_price, 0.0
    change_column_default :order_article_results, :deposit, 0.0
    change_column_default :orders, :deposit, 0.0
    change_column_default :orders, :deposit_credit, 0.0
  end

  def self.down
  end
end
