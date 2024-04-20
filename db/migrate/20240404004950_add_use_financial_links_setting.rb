class AddUseFinancialLinksSetting < ActiveRecord::Migration[7.0]
  def up
    FoodsoftConfig[:use_financial_links] = true if FinancialLink.any? || FinancialTransaction.where(ordergroup: nil).any?
  end

  def down
    FoodsoftConfig[:use_financial_links] = nil
  end
end
