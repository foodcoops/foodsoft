require 'csv'

class FinancialTransactionsCsv < RenderCSV
  include ApplicationHelper

  def header
    [
      FinancialTransaction.human_attribute_name(:created_on),
      FinancialTransaction.human_attribute_name(:ordergroup),
      FinancialTransaction.human_attribute_name(:ordergroup),
      FinancialTransaction.human_attribute_name(:user),
      FinancialTransaction.human_attribute_name(:financial_transaction_class),
      FinancialTransaction.human_attribute_name(:financial_transaction_type),
      FinancialTransaction.human_attribute_name(:note),
      FinancialTransaction.human_attribute_name(:amount)
    ]
  end

  def data
    @object.includes(:user, :ordergroup, :financial_transaction_type).each do |t|
      yield [
        t.created_on,
        t.ordergroup_id,
        t.ordergroup_name,
        show_user(t.user),
        t.financial_transaction_type.financial_transaction_class.name,
        t.financial_transaction_type.name,
        t.note,
        number_to_currency(t.amount)
      ]
    end
  end
end
