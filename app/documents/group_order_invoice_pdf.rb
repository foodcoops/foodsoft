class GroupOrderInvoicePdf < RenderPDF
  def filename
    I18n.t('documents.group_order_invoice_pdf.filename', :number => @options[:invoice_number]) + '.pdf'
  end

  def title
    I18n.t('documents.group_order_invoice_pdf.title', :supplier => @options[:supplier])
  end

  def body
    contact = FoodsoftConfig[:contact].symbolize_keys
    ordergroup = @options[:ordergroup]

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
      unless contact[:phone].blank?
        text "#{Supplier.human_attribute_name :phone}: #{contact[:phone]}", size: fontsize(9), align: :left
        move_down 5
      end
      unless contact[:email].blank?
        text "#{Supplier.human_attribute_name :email}: #{contact[:email]}", size: fontsize(9), align: :left
      end
      move_down 5
      text I18n.t('documents.group_order_invoice_pdf.tax_number', :number => @options[:tax_number]), size: fontsize(9), align: :left
    end

    # Receiving Ordergroup
    bounding_box [margin_box.left, margin_box.top - 20], width: 200 do
      text I18n.t('documents.group_order_invoice_pdf.invoicee')
      move_down 7
      text I18n.t('documents.group_order_invoice_pdf.ordergroup.name', ordergroup: ordergroup.name.to_s), size: fontsize(9)
      move_down 5
      if ordergroup.contact_address
        text I18n.t('documents.group_order_invoice_pdf.ordergroup.contact_address', contact_address: ordergroup.contact_address.to_s), size: fontsize(9)
        move_down 5
      end
      if ordergroup.contact_phone
        text I18n.t('documents.group_order_invoice_pdf.ordergroup.contact_phone', contact_phone: ordergroup.contact_phone.to_s), size: fontsize(9)
        move_down 5
      end
    end

    # invoice Date and nnvoice number
    bounding_box [margin_box.right - 200, margin_box.top - 150], width: 200 do
      text I18n.t('documents.group_order_invoice_pdf.invoice_date', invoice_date: @options[:invoice_date].strftime(I18n.t('date.formats.default'))), align: :left
      move_down 5
      text I18n.t('documents.group_order_invoice_pdf.invoice_number', invoice_number: @options[:invoice_number]), align: :left
    end

    move_down 15

    # kind of the "body" of the invoice
    text I18n.t('documents.group_order_invoice_pdf.payment_method', payment_method: @options[:payment_method])
    move_down 15
    text I18n.t('documents.group_order_invoice_pdf.table_headline')
    move_down 5

    #------------- Table Data -----------------------

    @group_order = GroupOrder.find(@options[:group_order].id)
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
    group_order_articles = GroupOrderArticle.where(group_order_id: @group_order.id)
    group_order_articles.each do |goa|
      # if no unit is received, nothing is to be charged
      next if goa.result.to_i == 0
      goa_total_gross = goa.result * goa.order_article.price.gross_price
      data << [goa.order_article.article.name,
               goa.result.to_i,
               number_to_currency(goa.order_article.price.gross_price),
               number_to_currency(goa.total_price)]
      total_gross += goa_total_gross
    end

    table data, position: :left, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      table.header = true
      table.position = :center
      table.cells.border_width = 1
      table.cells.border_color = '666666'

      table.row(0).column(1).width = 40
      table.row(0).border_bottom_width = 2
      table.columns(1).align = :right
      table.columns(1..6).align = :right
    end

    move_down 5
    sum = []
    sum << [nil, nil, I18n.t('documents.group_order_invoice_pdf.sum_to_pay'), number_to_currency(total_gross)]
    # table for sum
    indent(200) do
      table sum, position: :center, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
        sum.length.times do |count|
          table.row(count).columns(0..3).borders = []
        end
        table.row(sum.length - 1).columns(0..2).borders = []
        table.row(sum.length - 1).border_bottom_width = 2
        table.row(sum.length - 1).columns(3).borders = [:bottom]
      end
    end

    move_down 25
    text I18n.t('documents.group_order_invoice_pdf.small_business_regulation')
    move_down 10
  end

  def body_with_vat
    total_gross = 0
    total_net = 0
    # Articles

    tax_hash_net = Hash.new(0) # for summing up article net prices grouped into vat percentage
    tax_hash_gross = Hash.new(0) # same here with gross prices

    marge = FoodsoftConfig[:price_markup]

    # data table looks different when price_markup > 0
    data = if marge == 0
             [I18n.t('documents.group_order_invoice_pdf.no_price_markup_rows')]
           else
             [I18n.t('documents.group_order_invoice_pdf.price_markup_rows', marge: marge)]
           end
    goa_tax_hash = GroupOrderArticle.where(group_order_id: @group_order.id).find_each.group_by { |oat| oat.order_article.price.tax }
    goa_tax_hash.each do |tax, group_order_articles|
      group_order_articles.each do |goa|
        # if no unit is received, nothing is to be charged
        next if goa.result.to_i == 0

        order_article = goa.order_article
        goa_total_net = goa.result * order_article.price.price
        goa_total_gross = goa.result * order_article.price.gross_price
        data << [order_article.article.name,
                 goa.result.to_i,
                 number_to_currency(order_article.price.price),
                 number_to_currency(goa_total_net),
                 tax.to_s + '%',
                 number_to_currency(goa.total_price)]
        tax_hash_net[tax.to_i] += goa_total_net
        tax_hash_gross[tax.to_i] += goa_total_gross
        total_net += goa_total_net
        total_gross += goa_total_gross
      end
    end

    # Two separate tables for sum and individual data
    # article information + data
    table data, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      table.header = true
      table.position = :center
      table.cells.border_width = 1
      table.cells.border_color = '666666'

      table.row(0).column(1).width = 40
      table.row(0).border_bottom_width = 2
      table.columns(1).align = :right
      table.columns(1..6).align = :right
    end

    sum = []
    sum << [nil, nil, nil, nil, I18n.t('documents.group_order_invoice_pdf.sum_to_pay_net'), number_to_currency(total_net)]
    tax_hash_net.each_key.each do |tax|
      sum << [nil, nil, nil, nil, I18n.t('documents.group_order_invoice_pdf.tax_included', tax: tax), number_to_currency(tax_hash_gross[tax] - tax_hash_net[tax])]
    end
    unless marge == 0
      sum << [nil, nil, nil, nil, I18n.t('documents.group_order_invoice_pdf.markup_included', marge: marge), number_to_currency(total_gross * marge / 100.0)]
    end
    end_sum = total_gross * (1 + marge / 100.0)
    sum << [nil, nil, nil, nil, I18n.t('documents.group_order_invoice_pdf.sum_to_pay_gross'), number_to_currency(end_sum)]
    # table for sum
    table sum, position: :right, cell_style: { size: fontsize(8), overflow: :shrink_to_fit } do |table|
      sum.length.times do |count|
        table.row(count).columns(0..5).borders = []
      end
      table.row(sum.length - 1).columns(0..4).borders = []
      table.row(sum.length - 1).border_bottom_width = 2
      table.row(sum.length - 1).columns(5).borders = [:bottom]
    end

    if(FoodsoftConfig[:group_order_invoices][:vat_exempt])
      move_down 15
      text I18n.t('documents.group_order_invoice_pdf.small_business_regulation')
    end
    move_down 10
  end
end
