class FinanceReport < RenderPDF
  def initialize(range, options = {})
    @range = range
    super(options)

    @ftt_has_multiple_types = FinancialTransactionType.has_multiple_types
    @ftc_sorted = FinancialTransactionClass.sorted
  end

  def filename
    I18n.t('documents.finance_report.filename') + '.pdf'
  end

  def title
    false
  end

  def new_page(title, layout = :portrait)
    start_new_page(layout: layout)
    text title, size: 18, style: :bold
    move_down 15

    @started_new_page = true
  end

  def sub_page(title)
    move_down 15 unless @started_new_page
    @started_new_page = false

    text title, size: 14, style: :bold
  end

  def body
    body_overview
    body_invoices
    body_group(nil, 'Allgemein')
    body_groups_overview
    body_groups
    body_bank_accounts
  end

  def body_overview
    text 'Finanzbericht', size: 32
    text "Zeitraum: #{@range.begin} bis #{@range.end}"
    move_down 15

    body_overview_ordergoups
    body_overview_bank_accounts
    body_overview_general
  end

  def body_overview_ordergoups
    sub_page 'Bestellgruppen'

    nice_table_old_in_out_new heading_helper(Ordergroup, :name) do |t|
      sums_begin = FinancialTransactionClass
                   .joins(financial_transaction_types: [:financial_transactions])
                   .where.not(financial_transactions: { ordergroup_id: nil })
                   .where('financial_transactions.created_on < ?', @range.begin)
                   .group(:id)
                   .sum(:amount)

      sums_end = FinancialTransactionClass
                 .joins(financial_transaction_types: [:financial_transactions])
                 .where.not(financial_transactions: { ordergroup_id: nil })
                 .where('financial_transactions.created_on < ?', @range.end)
                 .group(:id)
                 .sum(:amount)

      financial_transaction_classes = FinancialTransactionClass
                                      .joins(financial_transaction_types: [:financial_transactions])
                                      .where.not(financial_transactions: { ordergroup_id: nil })
                                      .where(financial_transactions: { created_on: @range })
                                      .group(:id)
                                      .order(:name)
                                      .select(:id, :name,
                                              'SUM(CASE WHEN financial_transactions.amount < 0 THEN financial_transactions.amount ELSE 0 END) AS sum_amount_negative',
                                              'SUM(CASE WHEN financial_transactions.amount > 0 THEN financial_transactions.amount ELSE 0 END) AS sum_amount_positive',
                                              'SUM(financial_transactions.amount) AS sum_amount')

      financial_transaction_classes.each do |row|
        sum_begin = sums_begin[row.id] || 0
        sum_end = sums_end[row.id] || 0
        t.row row.name, sum_begin, row.sum_amount_positive, row.sum_amount_negative, sum_end
      end
    end
  end

  def body_overview_bank_accounts
    sub_page 'Bankkonten'

    nice_table_old_in_out_new heading_helper(BankAccount, :name) do |t|
      sums_begin = BankAccount
                   .joins(:bank_transactions)
                   .where('bank_transactions.date < ?', @range.begin)
                   .group(:id)
                   .sum(:amount)

      sums_transactions = BankAccount
                          .joins(:bank_transactions)
                          .where(bank_transactions: { date: @range })
                          .group(:id)
                          .select(:id, :name,
                                  'SUM(CASE WHEN bank_transactions.amount > 0 THEN bank_transactions.amount ELSE 0 END) AS sum_amount_positive',
                                  'SUM(CASE WHEN bank_transactions.amount < 0 THEN bank_transactions.amount ELSE 0 END) AS sum_amount_negative')

      sums_end = BankAccount
                 .joins(:bank_transactions)
                 .where('bank_transactions.date < ?', @range.end)
                 .group(:id)
                 .sum(:amount)

      BankAccount.order(:name).each do |bank_account|
        sum_begin = sums_begin[bank_account.id] || 0
        sum_transactions = sums_transactions.detect { |item| item.id == bank_account.id }
        sum_amount_positive = sum_transactions.try(:sum_amount_positive) || 0
        sum_amount_negative = sum_transactions.try(:sum_amount_negative) || 0
        sum_end = sums_end[bank_account.id] || 0
        t.row bank_account.name, sum_begin, sum_amount_positive, sum_amount_negative, sum_end
      end
    end
  end

  def body_overview_general
    sub_page 'Allgemein'

    nice_table do |t|
      t.header [
        heading_helper(FinancialTransactionType, :name)
      ]

      inital_sums = FinancialTransaction
                    .where(ordergroup_id: nil)
                    .includes(:financial_transaction_type)
                    .where('created_on < ?', @range.begin)
                    .group(:financial_transaction_class_id)
                    .sum(:amount)

      inital_invoices_sums = Invoice
                             .joins(supplier: [:supplier_category])
                             .where('paid_on < ?', @range.begin)
                             .group(:financial_transaction_class_id)
                             .sum(:amount)
                             .transform_values(&:-@)

      inital_sums.merge!(inital_invoices_sums) { |_key, v1, v2| v1 + v2 }

      financial_transactions = FinancialTransactionType
                               .joins(:financial_transactions)
                               .where(financial_transactions: { created_on: @range, ordergroup_id: nil })
                               .group(:name)
                               .order(:name)
                               .pluck('financial_transaction_types.name',
                                      'financial_transaction_types.financial_transaction_class_id',
                                      'SUM(financial_transactions.amount)')

      invoices = Invoice
                 .joins(:supplier)
                 .joins('LEFT JOIN supplier_categories ON supplier_categories.id = suppliers.supplier_category_id')
                 .where(invoices: { paid_on: @range })
                 .group(:supplier_category_id)
                 .pluck('supplier_categories.name',
                        'supplier_categories.financial_transaction_class_id',
                        'SUM(invoices.amount)')

      t.row 'Übertrag', inital_sums unless inital_sums.empty?

      financial_transactions.each do |row|
        t.row("Kontotransaktionen: #{row[0]}", { row[1] => row[2] })
      end

      invoices.each do |row|
        t.row("Rechnungen: #{row[0]}", { row[1] => -row[2] })
      end
    end
  end

  def body_invoices
    new_page 'Rechnungen'

    SupplierCategory.order(:name).each do |c|
      body_invoice(c.id, c.name)
    end
  end

  def body_invoice(supplier_category_id, name)
    sub_page name

    nice_table 1 do |t|
      t.header [
        heading_helper(Invoice, :paid_on),
        heading_helper(Invoice, :supplier),
        heading_helper(Invoice, :number),
        heading_helper(Invoice, :amount)
      ]

      invoices = Invoice
                 .includes(:supplier)
                 .references(:supplier)
                 .where(paid_on: @range, suppliers: { supplier_category_id: supplier_category_id })
                 .order(:paid_on)
                 .pluck(:paid_on, 'suppliers.name', :number, :amount)

      invoices.each do |invoice|
        t.row format_date(invoice[0]), invoice[1], invoice[2], invoice[3]
      end
    end
  end

  def body_groups_overview
    new_page "Kontotransaktionen der Bestellgruppen"

    FinancialTransactionClass.order(:name).each do |row|
      body_groups_overview2(row.id, row.name)
    end
  end

  def body_groups_overview2(id, name)
    sub_page name

    nice_table 3 do |t|
      t.header [
        heading_helper(FinancialTransactionClass, :name),
        'Eingang',
        'Ausgang',
        'Summe'
      ]

      FinancialTransactionType
        .joins(:financial_transactions)
        .where(financial_transaction_class: id)
        .where(financial_transactions: { created_on: @range })
        .where.not(financial_transactions: { ordergroup_id: nil })
        .group(:name)
        .order(:name)
        .select(:name,
                'SUM(CASE WHEN financial_transactions.amount < 0 THEN financial_transactions.amount ELSE 0 END) AS sum_amount_negative',
                'SUM(CASE WHEN financial_transactions.amount > 0 THEN financial_transactions.amount ELSE 0 END) AS sum_amount_positive',
                'SUM(financial_transactions.amount) AS sum_amount').each do |ftt|
        t.row ftt.name, ftt.sum_amount_positive, ftt.sum_amount_negative, ftt.sum_amount
      end
    end
  end

  def body_groups
    Ordergroup.includes(:financial_transactions)
              .where(financial_transactions: { created_on: @range })
              .where.not(id: 0).order(:name).group(:id).pluck(:id, :name).each do |og|
      body_group(og[0], "#{Ordergroup.model_name.human} #{og[1]}")
    end
  end

  def body_group(og_id, og_name)
    new_page og_name, :landscape

    nice_table do |ta|
      ta.header [
        heading_helper(FinancialTransaction, :created_on),
        heading_helper(FinancialTransaction, :financial_transaction_type),
        heading_helper(FinancialTransaction, :note)
      ]

      if og_id
        inital_sums = FinancialTransaction.where(ordergroup_id: og_id)
                                          .includes(:financial_transaction_type)
                                          .where('created_on < ?', @range.begin)
                                          .group(:financial_transaction_class_id)
                                          .sum(:amount)

        ta.row 'Übertrag', nil, nil, inital_sums unless inital_sums.empty?
      end

      FinancialTransaction.where(ordergroup_id: og_id, created_on: @range)
                          .includes(:financial_transaction_type).order(:created_on)
                          .pluck(:created_on, 'financial_transaction_types.name', :note, 'financial_transaction_types.financial_transaction_class_id', :amount).each do |t|
        ta.row(format_date(t[0]), t[1], t[2], { t[3] => t[4] })
      end
    end
  end

  def body_bank_accounts
    inital_sums = BankAccount
                  .includes(:bank_transactions)
                  .where('date < ?', @range.begin)
                  .group(:id)
                  .sum(:amount)

    BankAccount.order(:name).each do |bank_account|
      new_page "Bankkonto #{bank_account.name}", :landscape

      nice_table 1 do |t|
        t.header [
          heading_helper(BankTransaction, :date),
          heading_helper(BankTransaction, :text),
          heading_helper(BankTransaction, :reference),
          heading_helper(BankTransaction, :amount)
        ]

        inital_sum = inital_sums[bank_account.id]
        t.row 'Übertrag', nil, nil, inital_sum if inital_sum

        bank_transactions = bank_account.bank_transactions.where(date: @range).order(:date)
        bank_transactions.each do |bt|
          t.row format_date(bt.date), bt.text, bt.reference, bt.amount
        end
      end
    end
  end

  class Table
    include ActionView::Helpers::NumberHelper

    attr_reader :sum_cols

    def initialize(sum_cols)
      @sum_cols = sum_cols
      @data = []
      @found = Set.new
    end

    def header(h)
      @header = h
    end

    def row(*args)
      @data << args

      unless @sum_cols
        ftc = args.last
        ftc.each_key { |key| @found << key }
      end
    end

    def data
      unless @sum_cols
        ftc_map = {}
        FinancialTransactionClass.sorted.find(@found.to_a).each do |ftc|
          ftc_map[ftc.id] = @header.length
          @header << ftc.name
        end
        @sum_cols = ftc_map.size

        @data.map! do |row|
          ret = row[0..-2]
          @sum_cols.times { ret << nil }

          row[-1].each do |key, value|
            col = ftc_map[key]
            ret[col] = value if col
          end

          ret
        end
      end

      sum_row = []
      @header.length.times { sum_row << nil }

      range = @header.length - @sum_cols..@header.length - 1

      range.each do |idx|
        sum_row[idx] = 0
      end

      @data.each do |r|
        range.each do |idx|
          sum_row[idx] += r[idx] if r[idx]
          r[idx] = number_to_currency(r[idx])
        end
      end

      sum_row[0] = 'Summe'
      range.each do |idx|
        sum_row[idx] = number_to_currency(sum_row[idx])
      end

      [@header, *@data, sum_row]
    end
  end

  def nice_table_old_in_out_new(name)
    nice_table 4 do |t|
      t.header [
        name,
        'Alt',
        'Eingang',
        'Ausgang',
        'Neu'
      ]
      yield t
    end
  end

  def nice_table(sum_count = nil)
    t = Table.new sum_count

    yield t

    data = t.data
    sum_cols = t.sum_cols

    table data, width: bounds.width, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      table.header = true
      table.cells.border_width = 1
      table.cells.border_color = '666666'

      table.cells.borders = [:bottom]

      table.row(0).border_bottom_width = 2

      w = data[0].length - 1
      table.columns(w - sum_cols + 1..w).align = :right
      table.columns(w - sum_cols + 1..w).width = 70
      table.row(data.length - 1).columns(0..w).borders = [:top]
      table.row(data.length - 1).border_top_width = 2
    end
  end
end
