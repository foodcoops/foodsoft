require 'csv'

class FinancialTransactionsCsv < RenderCSV
  include ApplicationHelper

  def header
    [
      FinancialTransaction.human_attribute_name(:created_on),
      FinancialTransaction.human_attribute_name(:ordergroup),
      FinancialTransaction.human_attribute_name(:ordergroup),
      FinancialTransaction.human_attribute_name(:user),
      FinancialTransaction.human_attribute_name(:note),
      FinancialTransaction.human_attribute_name(:amount)
    ]
  end

  def data
    @object.includes(:user, :ordergroup).each do |t|
      yield [
              t.created_on,
              t.ordergroup_id,
              t.ordergroup.name,
              show_user(t.user),
              t.note,
              number_to_currency(t.amount)
            ]
    end
  end
end
