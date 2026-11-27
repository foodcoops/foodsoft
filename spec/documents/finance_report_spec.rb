require_relative '../spec_helper'

describe FinanceReport do
  let(:ordergroup) { create(:ordergroup) }
  let(:type) { create(:financial_transaction_type) }
  let(:transaction_class) { type.financial_transaction_class }
  let(:range) { Date.new(2024, 1, 1)..Date.new(2024, 1, 31) }

  def report
    described_class.new(range).to_pdf
  end

  # Translated section labels as they appear in the rendered pdf.
  def label(key, **options)
    I18n.t("documents.finance_report.#{key}", **options)
  end

  it 'renders a pdf with the report title' do
    pdf = report

    expect(pdf).to start_with('%PDF')
    expect(pdf).to include_text(label('title'))
  end

  it 'includes transactions of the given period' do
    create(:financial_transaction, ordergroup: ordergroup, financial_transaction_type: type,
                                   created_on: range.begin.midnight, amount: 12.34, note: 'in period')
    create(:financial_transaction, ordergroup: ordergroup, financial_transaction_type: type,
                                   created_on: (range.end + 5.days).midnight, amount: 42, note: 'out of period')

    expect(report).to include_text(ordergroup.name, 'in period')
      .and not_include_text('out of period')
  end

  it 'carries over balances from before the period' do
    create(:financial_transaction, ordergroup: ordergroup, financial_transaction_type: type,
                                   created_on: (range.begin - 10.days).midnight, amount: -5, note: 'before period')

    expect(report).to include_text(transaction_class.name, label('carry_over'))
  end

  it 'includes transactions on the last day of the period' do
    create(:financial_transaction, ordergroup: ordergroup, financial_transaction_type: type,
                                   created_on: range.end.midnight + 14.hours,
                                   amount: 9.99, note: 'late on the last day')
    create(:financial_transaction, ordergroup: ordergroup, financial_transaction_type: type,
                                   created_on: (range.end + 1.day).midnight,
                                   amount: 11.11, note: 'just after the period')

    expect(report).to include_text('late on the last day')
      .and not_include_text('just after the period')
  end

  it 'counts the last day of the period in the closing balance' do
    # The closing balance is a sum, so assert on the transaction that must feed
    # it rather than on formatted currency output.
    create(:financial_transaction, ordergroup: ordergroup, financial_transaction_type: type,
                                   created_on: range.end.midnight + 14.hours,
                                   amount: 40, note: 'on the last day')

    expect(report).to include_text('on the last day')
  end

  it 'renders bank accounts and their transactions' do
    bank_account = create(:bank_account)
    create(:bank_transaction, bank_account: bank_account, date: range.begin,
                              amount: 7.77, text: 'bank text', reference: 'bank reference')

    expect(report).to include_text(bank_account.name, 'bank text', 'bank reference')
  end

  it 'includes bank transactions on the last day of the period' do
    bank_account = create(:bank_account)
    create(:bank_transaction, bank_account: bank_account, date: range.end,
                              amount: 5.55, text: 'last day bank text')
    create(:bank_transaction, bank_account: bank_account, date: range.end + 1.day,
                              amount: 6.66, text: 'after period bank text')

    expect(report).to include_text('last day bank text')
      .and not_include_text('after period bank text')
  end

  it 'includes invoices paid on the last day of the period' do
    invoice = create(:invoice, amount: 30, paid_on: range.end, number: 4321)

    expect(report).to include_text(invoice.number.to_s)
  end

  it 'renders invoices paid within the period' do
    invoice = create(:invoice, amount: 20, paid_on: range.begin)

    expect(report).to include_text(invoice.number.to_s, '20.00')
  end

  it 'omits the general page when all transactions belong to an ordergroup' do
    create(:financial_transaction, ordergroup: ordergroup, financial_transaction_type: type,
                                   created_on: range.begin.midnight, amount: 12.34)

    expect(report).to include_text(label('title'))
      .and not_include_text(label('general'))
  end

  it 'renders the general page for transactions without an ordergroup' do
    create(:financial_transaction, ordergroup: nil, financial_transaction_type: type,
                                   created_on: range.begin.midnight, amount: 3.33, note: 'foodcoop expense')

    expect(report).to include_text(label('general'), 'foodcoop expense')
  end

  it 'renders the general page for unassigned transactions outside the period' do
    create(:financial_transaction, ordergroup: nil, financial_transaction_type: type,
                                   created_on: (range.begin - 10.days).midnight,
                                   amount: -20, note: 'foodcoop carried over')

    expect(report).to include_text(label('general'), label('carry_over'))
  end

  describe '#filename' do
    it 'is localized and includes the period' do
      expect(described_class.new(range).filename)
        .to eq(I18n.t('documents.finance_report.filename', begin: range.begin, end: range.end) + '.pdf')
    end
  end
end
