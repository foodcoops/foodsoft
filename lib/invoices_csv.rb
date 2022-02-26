require 'csv'

class InvoicesCsv < RenderCSV
  include ApplicationHelper

  def header
    [
      Invoice.human_attribute_name(:created_at),
      Invoice.human_attribute_name(:created_by),
      Invoice.human_attribute_name(:date),
      Invoice.human_attribute_name(:supplier),
      Invoice.human_attribute_name(:number),
      Invoice.human_attribute_name(:amount),
      Invoice.human_attribute_name(:total),
      Invoice.human_attribute_name(:deposit),
      Invoice.human_attribute_name(:deposit_credit),
      Invoice.human_attribute_name(:paid_on),
      Invoice.human_attribute_name(:note)
    ]
  end

  def data
    @object.each do |t|
      yield [
        t.created_at,
        show_user(t.created_by),
        t.date,
        t.supplier.name,
        t.number,
        t.amount,
        t.expected_amount,
        t.deposit,
        t.deposit_credit,
        t.paid_on,
        t.note,
      ]
    end
  end
end
