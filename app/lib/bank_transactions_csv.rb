require 'csv'

class BankTransactionsCsv < RenderCSV
  include ApplicationHelper

  def header
    [
      BankTransaction.human_attribute_name(:external_id),
      BankTransaction.human_attribute_name(:date),
      BankTransaction.human_attribute_name(:amount),
      BankTransaction.human_attribute_name(:iban),
      BankTransaction.human_attribute_name(:reference),
      BankTransaction.human_attribute_name(:text)
    ]
  end

  def data
    @object.each do |t|
      yield [
        t.external_id,
        t.date,
        t.amount,
        t.iban,
        t.reference,
        t.text
      ]
    end
  end
end
