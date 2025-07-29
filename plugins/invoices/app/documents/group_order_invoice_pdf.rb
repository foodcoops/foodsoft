class GroupOrderInvoicePdf < RenderPdf
  def filename
    ordergroup_name = @options[:ordergroup].name || "OrderGroup"
    "#{ordergroup_name}_" + I18n.t('documents.group_order_invoice_pdf.filename', :number => @options[:invoice_number]) + '.pdf'
  end

  def title
    I18n.t('documents.group_order_invoice_pdf.title', :supplier => @options[:supplier])
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
      text I18n.t('documents.group_order_invoice_pdf.tax_number', :number => @options[:tax_number]), size: fontsize(9), align: :left
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
      if ordergroup.customer_number.present?
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
    total_gross = 0
    data = [I18n.t('documents.group_order_invoice_pdf.vat_exempt_rows')]
    move_down 10
    # no sinle group_order_id, capice? get all the articles.

    group_order_articles = GroupOrderArticle.where(group_order_id: @options[:group_order_ids])
    separate_deposits = FoodsoftConfig[:group_order_invoices]&.[](:separate_deposits)
    supplier = ""
    group_order_articles.each do |goa|
      # if no unit is received, nothing is to be charged
      next if goa.result.to_i == 0
      if goa.group_order.order.supplier.name != supplier
        supplier = goa.group_order.order.supplier.name
        data << [supplier,"","",""]
      end
      goa_total_price = separate_deposits ? goa.total_price_without_deposit : goa.total_price
      data << [goa.order_article.article.name,
               goa.result.to_i,
               number_to_currency(goa.order_article.price.fc_price_without_deposit),
               number_to_currency(goa_total_price)]
      total_gross += goa_total_price
      next unless separate_deposits && goa.order_article.price.deposit > 0.0

      goa_total_deposit = goa.result * goa.order_article.price.fc_deposit_price
      data << ["zzgl. Pfand",
               goa.result.to_i,
               number_to_currency(goa.order_article.article.fc_deposit_price),
               number_to_currency(goa_total_deposit)]
      total_gross += goa_total_deposit
    end

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

    move_down 5
    sum = []
    sum << [nil, nil, I18n.t('documents.group_order_invoice_pdf.sum_to_pay_gross'), number_to_currency(total_gross)]
    # table for sum
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

    move_down 25
    text I18n.t('documents.group_order_invoice_pdf.small_business_regulation')
    move_down 10
  end

  def body_with_vat
    separate_deposits = FoodsoftConfig[:group_order_invoices]&.[](:separate_deposits)
    total_gross = 0
    total_net = 0
    # Articles

    tax_hash_net = Hash.new(0) # for summing up article net prices grouped into vat percentage
    tax_hash_gross = Hash.new(0) # same here with gross prices
    tax_hash_fc = Hash.new(0) # same here with fc prices

    if separate_deposits
      total_deposit = 0
      total_deposit_gross = 0

      tax_hash_deposit_gross = Hash.new(0) # for summing up deposit gross prices grouped into vat percentage
      tax_hash_deposit_net = Hash.new(0) # same here with gross prices
      tax_hash_deposit_fc = Hash.new(0) # same here with fc prices
    end

    marge = FoodsoftConfig[:price_markup]

    # data table looks different when price_markup > 0
    data = if marge == 0
             [I18n.t('documents.group_order_invoice_pdf.no_price_markup_rows')]
           else
             [I18n.t('documents.group_order_invoice_pdf.price_markup_rows', marge: marge)]
           end
    
    group_order_articles = GroupOrderArticle.where(group_order_id: @options[:group_order_ids]).includes(group_order: { order: :supplier })

    group_order_articles.group_by { |goa| goa.group_order.order.supplier.name }.each do |supplier_name, articles|
      if articles.map(&:result).sum > 0
        data << [supplier_name, "", "", "", "", ""]
      end

      articles.each do |goa|
        next if goa.result.to_i == 0

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

        if separate_deposits && order_article.price.deposit > 0.0
          goa_net_deposit = goa.result * order_article.price.net_deposit_price
          goa_deposit = goa.result * order_article.price.deposit
          goa_total_deposit = goa.result * order_article.price.fc_deposit_price

          data << ["zzgl. Pfand",
                   goa.result.to_i,
                   number_to_currency(order_article.price.net_deposit_price),
                   number_to_currency(goa_net_deposit),
                   tax.to_s + '%',
                   number_to_currency(goa_total_deposit)]

          total_deposit += goa_deposit
          total_deposit_gross += goa_total_deposit

          tax_hash_deposit_net[tax.to_i] += goa_net_deposit
          tax_hash_deposit_gross[tax.to_i] += goa_deposit
          tax_hash_deposit_fc[tax.to_i] += goa_total_deposit
        end

        tax_hash_net[tax.to_i] += goa_total_net
        tax_hash_gross[tax.to_i] += goa_total_gross
        tax_hash_fc[tax.to_i] += goa_total_fc

        total_net += goa_total_net
        total_gross += goa_total_fc
      end
    end

    # Two separate tables for sum and individual data
    # article information + data
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

    if marge > 0
      sum = [[nil, nil, "Netto", "MwSt", "FC-Marge", "Brutto"]]
    else
      sum = [[nil, nil, nil, "Netto", "MwSt", "Brutto"]]
    end

    tax_hash_gross.keys.each do |key|
      tmp_sum = [nil, "Produkte mit #{key}%", number_to_currency(tax_hash_net[key])]
      if marge <= 0
        tmp_sum.unshift(nil)
      end
      tmp_sum << number_to_currency(tax_hash_gross[key] - tax_hash_net[key])
      if marge > 0
        tmp_sum << number_to_currency(tax_hash_fc[key] - tax_hash_gross[key])
      end
      tmp_sum << number_to_currency(tax_hash_fc[key])
      sum << tmp_sum


      if separate_deposits
        tmp_sum = [nil, "Pfand mit #{key}%", number_to_currency(tax_hash_deposit_net[key])]
        if marge <= 0
          tmp_sum.unshift(nil)
        end
        tmp_sum << number_to_currency(tax_hash_deposit_gross[key] - tax_hash_deposit_net[key])
        if marge > 0
          tmp_sum << number_to_currency(tax_hash_deposit_fc[key] - tax_hash_deposit_gross[key])
        end
        tmp_sum << number_to_currency(tax_hash_deposit_fc[key])
        sum << tmp_sum
      end
    end

    total_deposit_gross ||= 0
    sum << [nil, nil, nil, nil, I18n.t('documents.group_order_invoice_pdf.sum_to_pay_gross'), number_to_currency(total_gross + total_deposit_gross)]

    move_down 10
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

    if FoodsoftConfig[:group_order_invoices][:vat_exempt]
      move_down 15
      text I18n.t('documents.group_order_invoice_pdf.small_business_regulation')
    end
    move_down 10
  end
end
