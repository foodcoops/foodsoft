module PathHelper
  def finance_group_transactions_path(ordergroup)
    if ordergroup
      finance_ordergroup_transactions_path(ordergroup)
    else
      finance_foodcoop_financial_transactions_path
    end
  end
end
