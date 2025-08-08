class GroupOrderInvoicePdf < RenderPdf
  def filename
    ordergroup_name = @options[:ordergroup].name || 'OrderGroup'
    "#{ordergroup_name}_" + I18n.t('documents.group_order_invoice_pdf.filename', number: @options[:invoice_number]) + '.pdf'
  end

  def title
    I18n.t('documents.group_order_invoice_pdf.title', supplier: @options[:supplier])
  end

  def body
    contact = FoodsoftConfig[:contact].symbolize_keys
    ordergroup = @options[:ordergroup]
    # TODO: group_by supplier, sort alphabetically
    # From paragraph
    bounding_box [margin_box.right - 200, margin_box.top - 20], width: 200 do
      text I18n.t('documents.group_order_invoice_pdf.invoicer')
      move_down 7
      text FoodsoftConfig[:name], size: fontsize(9), align: :left
      move_down 5
      text contact[:street], size: fontsize(9), align: :left
      move_down 5
      text "#{contact[:zip_code]} #{contact[:city]}", size: fontsize(9), align: :left
      move_down 5
      if contact[:phone].present?
        text "#{Supplier.human_attribute_name :phone}: #{contact[:phone]}", size: fontsize(9), align: :left
        move_down 5
      end
      text "#{Supplier.human_attribute_name :email}: #{contact[:email]}", size: fontsize(9), align: :left if contact[:email].present?
      move_down 5
      text I18n.t('documents.group_order_invoice_pdf.tax_number', number: @options[:tax_number]), size: fontsize(9), align: :left
    end

    # Receiving Ordergroup
    bounding_box [margin_box.left, margin_box.top - 20], width: 200 do
      text I18n.t('documents.group_order_invoice_pdf.invoicee')
      move_down 7
      text I18n.t('documents.group_order_invoice_pdf.ordergroup.name', ordergroup: ordergroup.name.to_s), size: fontsize(9)
      move_down 5
      if ordergroup.contact_address.present?
        text I18n.t('documents.group_order_invoice_pdf.ordergroup.contact_address', contact_address: ordergroup.contact_address.to_s), size: fontsize(9)
        move_down 5
      end
      if ordergroup.contact_phone.present?
        text I18n.t('documents.group_order_invoice_pdf.ordergroup.contact_phone', contact_phone: ordergroup.contact_phone.to_s), size: fontsize(9)
        move_down 5
      end
      if ordergroup.respond_to?(:customer_number) && ordergroup.customer_number.present?
        text I18n.t('documents.group_order_invoice_pdf.ordergroup.customer_number', customer_number: ordergroup.customer_number.to_s), size: fontsize(9)
        move_down 5
      end
    end

    # invoice Date and nnvoice number
    bounding_box [margin_box.right - 200, margin_box.top - 150], width: 200 do
      text I18n.t('documents.group_order_invoice_pdf.invoice_number', invoice_number: @options[:invoice_number]), align: :left
      move_down 5
      text I18n.t('documents.group_order_invoice_pdf.invoice_date', invoice_date: @options[:invoice_date].strftime(I18n.t('date.formats.default'))), align: :left
      if @options[:pickup]
        move_down 5
        text I18n.t('documents.group_order_invoice_pdf.pickup_date', invoice_date: @options[:pickup].strftime(I18n.t('date.formats.default')))
      end
    end

    move_down 20
    text I18n.t('documents.group_order_invoice_pdf.payment_method', payment_method: @options[:payment_method])
    text I18n.t('documents.group_order_invoice_pdf.table_headline')
    move_down 5

    #------------- Table Data -----------------------

    if FoodsoftConfig[:group_order_invoices][:vat_exempt]
      body_for_vat_exempt
    else
      body_with_vat
    end
  end

  def body_for_vat_exempt
    data = [I18n.t('documents.group_order_invoice_pdf.vat_exempt_rows')]
    move_down 10

    # Get all the articles
    group_order_articles = fetch_group_order_articles
    separate_deposits = FoodsoftConfig[:group_order_invoices]&.[](:separate_deposits)

    # Build data table
    data, total_gross = build_vat_exempt_data_table(data, group_order_articles, separate_deposits)

    # Render data table
    render_data_table(data)

    # Render sum table
    move_down 5
    render_vat_exempt_sum_table(total_gross)

    # Render footer text
    move_down 25
    text I18n.t('documents.group_order_invoice_pdf.small_business_regulation')
    move_down 10
  end

  # Fetches all group order articles for the invoice
  def fetch_group_order_articles
    GroupOrderArticle.where(group_order_id: @options[:group_order_ids])
  end

  # Builds the data table for VAT exempt invoices
  def build_vat_exempt_data_table(data, group_order_articles, separate_deposits)
    total_gross = 0
    supplier = ''

    group_order_articles.each do |goa|
      # Skip if no units received
      next if goa.result.to_i == 0

      # Add supplier header if it changed
      if goa.group_order.order.supplier.name != supplier
        supplier = goa.group_order.order.supplier.name
        data << [supplier, '', '', '']
      end

      # Add article row
      goa_total_price = separate_deposits ? goa.total_price_without_deposit : goa.total_price
      data << [goa.order_article.article.name,
               goa.result.to_i,
               number_to_currency(goa.order_article.price.fc_price_without_deposit),
               number_to_currency(goa_total_price)]
      total_gross += goa_total_price

      # Add deposit row if needed
      next unless separate_deposits && goa.order_article.price.deposit > 0.0

      goa_total_deposit = goa.result * goa.order_article.price.fc_deposit_price
      data << [I18n.t('documents.group_order_invoice_pdf.deposit_excluded'),
               goa.result.to_i,
               number_to_currency(goa.order_article.article.fc_deposit_price),
               number_to_currency(goa_total_deposit)]
      total_gross += goa_total_deposit
    end

    [data, total_gross]
  end

  # Renders the data table with proper formatting
  def render_data_table(data)
    table data, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      table.header = true
      table.position = :center
      table.cells.border_width = 1
      table.cells.border_color = '666666'
      table.row(0).column(0..4).width = 80
      table.row(0).column(0).width = 180
      table.row(0).border_bottom_width = 2
      table.columns(1).align = :right
      table.columns(1..6).align = :right
    end
  end

  # Renders the sum table for VAT exempt invoices
  def render_vat_exempt_sum_table(total_gross)
    sum = []
    sum << [nil, nil, I18n.t('documents.group_order_invoice_pdf.sum_to_pay_gross'), number_to_currency(total_gross)]

    table sum, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      table.header = true
      table.position = :center
      table.cells.border_width = 1
      table.cells.border_color = '666666'
      table.row(0).columns(2..4).style(align: :bottom)
      table.row(0).border_bottom_width = 2
      table.row(0..-1).columns(0..1).border_width = 0

      table.rows(0..-1).columns(0..4).width = 80
      table.row(0).column(0).width = 180
      table.row(0).column(-1).style(font_style: :bold)
      table.row(0).column(-2).style(font_style: :bold)
      table.row(0).column(-1).size = fontsize(10)
      table.row(0).column(-2).size = fontsize(10)

      table.columns(1).align = :right
      table.columns(1..6).align = :right
    end
  end

  def body_with_vat
    separate_deposits = FoodsoftConfig[:group_order_invoices]&.[](:separate_deposits)
    marge = FoodsoftConfig[:price_markup]

    # Initialize tax hashes and totals
    tax_hashes = initialize_tax_hashes(separate_deposits)

    # Build data table
    data = build_vat_data_header(marge)
    data, totals = build_vat_data_table(data, tax_hashes, separate_deposits)

    # Render data table
    render_vat_data_table(data)

    # Build and render sum table
    move_down 10
    sum = build_vat_sum_table(tax_hashes, totals, marge)
    render_vat_sum_table(sum, marge)

    # Render footer text if needed
    if FoodsoftConfig[:group_order_invoices][:vat_exempt]
      move_down 15
      text I18n.t('documents.group_order_invoice_pdf.small_business_regulation')
    end
    move_down 10
  end

  # Initialize tax hashes and totals for VAT calculations
  def initialize_tax_hashes(separate_deposits)
    result = {
      net: Hash.new(0),      # for summing up article net prices grouped into vat percentage
      gross: Hash.new(0),    # same here with gross prices
      fc: Hash.new(0),       # same here with fc prices
      totals: {
        gross: 0,
        net: 0
      }
    }

    if separate_deposits
      result[:deposit] = {
        gross: Hash.new(0),  # for summing up deposit gross prices grouped into vat percentage
        net: Hash.new(0),    # same here with gross prices
        fc: Hash.new(0),     # same here with fc prices
        totals: {
          deposit: 0,
          deposit_gross: 0
        }
      }
    end

    result
  end

  # Build the header row for the VAT data table
  def build_vat_data_header(marge)
    if marge == 0
      [I18n.t('documents.group_order_invoice_pdf.no_price_markup_rows')]
    else
      [I18n.t('documents.group_order_invoice_pdf.price_markup_rows', marge: marge)]
    end
  end

  # Build the data table for VAT included invoices
  def build_vat_data_table(data, tax_hashes, separate_deposits)
    group_order_articles = fetch_group_order_articles.includes(group_order: { order: :supplier })

    # Group articles by supplier
    group_order_articles.group_by { |goa| goa.group_order.order.supplier.name }.each do |supplier_name, articles|
      data << [supplier_name, '', '', '', '', ''] if articles.map(&:result).sum > 0

      # Process each article
      articles.each do |goa|
        next if goa.result.to_i == 0

        # Add article row
        data = add_article_row_with_vat(data, goa, tax_hashes, separate_deposits)

        # Add deposit row if needed
        data = add_deposit_row_with_vat(data, goa, tax_hashes) if separate_deposits && goa.order_article.price.deposit > 0.0
      end
    end

    # Extract totals from tax_hashes
    totals = {
      gross: tax_hashes[:totals][:gross],
      deposit_gross: tax_hashes[:deposit] ? tax_hashes[:deposit][:totals][:deposit_gross] : 0
    }

    [data, totals]
  end

  # Add an article row to the data table with VAT
  def add_article_row_with_vat(data, goa, tax_hashes, separate_deposits)
    order_article = goa.order_article
    tax = order_article.price.tax
    goa_total_net = goa.result * order_article.price.price

    goa_total_fc = separate_deposits ? goa.total_price_without_deposit : goa.total_price
    goa_total_gross = separate_deposits ? goa.result * order_article.price.gross_price_without_deposit : goa.result * order_article.price.gross_price

    data << [order_article.article_version.name,
             goa.result.to_i,
             number_to_currency(order_article.price.price),
             number_to_currency(goa_total_net),
             tax.to_s + '%',
             number_to_currency(goa_total_fc)]

    # Update tax hashes
    tax_hashes[:net][tax.to_i] += goa_total_net
    tax_hashes[:gross][tax.to_i] += goa_total_gross
    tax_hashes[:fc][tax.to_i] += goa_total_fc

    # Update totals
    tax_hashes[:totals][:net] += goa_total_net
    tax_hashes[:totals][:gross] += goa_total_fc

    data
  end

  # Add a deposit row to the data table with VAT
  def add_deposit_row_with_vat(data, goa, tax_hashes)
    order_article = goa.order_article
    tax = order_article.price.tax

    goa_net_deposit = goa.result * order_article.price.net_deposit_price
    goa_deposit = goa.result * order_article.price.deposit
    goa_total_deposit = goa.result * order_article.price.fc_deposit_price

    data << [I18n.t('documents.group_order_invoice_pdf.deposit_excluded'),
             goa.result.to_i,
             number_to_currency(order_article.price.net_deposit_price),
             number_to_currency(goa_net_deposit),
             tax.to_s + '%',
             number_to_currency(goa_total_deposit)]

    # Update deposit tax hashes
    tax_hashes[:deposit][:net][tax.to_i] += goa_net_deposit
    tax_hashes[:deposit][:gross][tax.to_i] += goa_deposit
    tax_hashes[:deposit][:fc][tax.to_i] += goa_total_deposit

    # Update deposit totals
    tax_hashes[:deposit][:totals][:deposit] += goa_deposit
    tax_hashes[:deposit][:totals][:deposit_gross] += goa_total_deposit

    data
  end

  # Render the data table for VAT included invoices
  def render_vat_data_table(data)
    table data, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      table.header = true
      table.position = :center
      table.cells.border_width = 1
      table.cells.border_color = '666666'
      table.row(0).columns(0..6).style(background_color: 'cccccc', font_style: :bold)
      table.rows(0..-1).columns(2..6).width = 80
      table.rows(0..-1).column(0).width = 170
      table.rows(0..-1).column(1).width = 40
      table.rows(0..-1).column(4).width = 60
      table.rows(0..-1).column(5).width = 90
      table.row(0).border_bottom_width = 2
      table.columns(1).align = :right
      table.columns(1..6).align = :right
    end
  end

  # Build the sum table for VAT included invoices
  def build_vat_sum_table(tax_hashes, totals, marge)
    sum = if marge > 0
            [[nil,
              nil,
              I18n.t('documents.group_order_invoice_pdf.vat_sum_table.net'),
              I18n.t('documents.group_order_invoice_pdf.vat_sum_table.tax'),
              I18n.t('documents.group_order_invoice_pdf.vat_sum_table.margin'),
              I18n.t('documents.group_order_invoice_pdf.vat_sum_table.gross')]]
          else
            [[nil,
              nil,
              nil,
              I18n.t('documents.group_order_invoice_pdf.vat_sum_table.net'),
              I18n.t('documents.group_order_invoice_pdf.vat_sum_table.tax'),
              I18n.t('documents.group_order_invoice_pdf.vat_sum_table.gross')]]
          end

    # Add rows for each tax rate
    tax_hashes[:gross].each_key do |key|
      # Add product row
      sum = add_tax_sum_row(sum, key, tax_hashes, I18n.t('documents.group_order_invoice_pdf.products'), marge)

      # Add deposit row if needed
      sum = add_tax_sum_row(sum, key, tax_hashes[:deposit], I18n.t('documents.group_order_invoice_pdf.deposit'), marge) if tax_hashes[:deposit] && tax_hashes[:deposit][:gross][key] > 0
    end

    # Add total row
    total_amount = totals[:gross] + totals[:deposit_gross]
    sum << [nil, nil, nil, nil, I18n.t('documents.group_order_invoice_pdf.sum_to_pay_gross'), number_to_currency(total_amount)]

    sum
  end

  # Add a tax sum row to the sum table
  def add_tax_sum_row(sum, tax_key, tax_hash, label, marge)
    tmp_sum = [nil, I18n.t('documents.group_order_invoice_pdf.tax_line', label: label, tax_key: tax_key), number_to_currency(tax_hash[:net][tax_key])]
    tmp_sum.unshift(nil) if marge <= 0
    tmp_sum << number_to_currency(tax_hash[:gross][tax_key] - tax_hash[:net][tax_key])
    tmp_sum << number_to_currency(tax_hash[:fc][tax_key] - tax_hash[:gross][tax_key]) if marge > 0
    tmp_sum << number_to_currency(tax_hash[:fc][tax_key])
    sum << tmp_sum
    sum
  end

  # Render the sum table for VAT included invoices
  def render_vat_sum_table(sum, marge)
    table sum, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      table.header = true
      table.position = :center
      table.cells.border_width = 1
      table.cells.border_color = '666666'
      table.row(0).columns(2..6).style(align: :bottom)
      table.row(0).border_bottom_width = 2
      table.row(0..-1).columns(0).border_width = 0
      table.row(0..-1).columns(1).border_width = 0 if marge <= 0
      table.rows(0..-1).columns(2..6).width = 80
      table.rows(0..-1).column(0).width = 110
      table.rows(0..-1).column(1).width = 100
      table.rows(0..-1).column(4).width = 60
      table.rows(0..-1).column(5).width = 90

      table.row(-1).column(-1).style(font_style: :bold)
      table.row(-1).column(-2).style(font_style: :bold)
      table.row(-1).column(-1).size = fontsize(10)
      table.row(-1).column(-2).size = fontsize(10)

      table.columns(1).align = :right
      table.columns(1..6).align = :right
    end
  end
end
