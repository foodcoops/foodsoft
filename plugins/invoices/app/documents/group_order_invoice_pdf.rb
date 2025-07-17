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

    # Header with invoicer and invoicee
    bounding_box [0, bounds.height], width: bounds.width do
      # Invoicer
      bounding_box [0, bounds.height], width: bounds.width / 2 - 10 do
        text I18n.t('documents.group_order_invoice_pdf.invoicer'), style: :bold
        text contact[:name]
        text contact[:street]
        text contact[:zip_code] + " " + contact[:city]
        text contact[:country]
        text contact[:email]
        text contact[:phone]
        move_down 5
        text I18n.t('documents.group_order_invoice_pdf.tax_number', number: @options[:tax_number])
      end

      # Invoicee
      bounding_box [bounds.width / 2, bounds.height], width: bounds.width / 2 - 10 do
        text I18n.t('documents.group_order_invoice_pdf.invoicee'), style: :bold
        text I18n.t('documents.group_order_invoice_pdf.ordergroup.name', ordergroup: @options[:ordergroup].name)

        if @options[:ordergroup].contact_address.present?
          text I18n.t('documents.group_order_invoice_pdf.ordergroup.contact_address', contact_address: @options[:ordergroup].contact_address)
        end

        if @options[:ordergroup].contact_phone.present?
          text I18n.t('documents.group_order_invoice_pdf.ordergroup.contact_phone', contact_phone: @options[:ordergroup].contact_phone)
        end

        text I18n.t('documents.group_order_invoice_pdf.ordergroup.customer_number', customer_number: @options[:ordergroup].id)
      end
    end

    move_down 20

    # Invoice details
    text I18n.t('documents.group_order_invoice_pdf.invoice_number', invoice_number: @options[:invoice_number]), style: :bold
    text I18n.t('documents.group_order_invoice_pdf.invoice_date', invoice_date: I18n.l(@options[:invoice_date], format: :default))
    text I18n.t('documents.group_order_invoice_pdf.payment_method', payment_method: @options[:payment_method])

    move_down 10

    # Table headline
    text I18n.t('documents.group_order_invoice_pdf.table_headline'), style: :bold

    move_down 10

    # Table with order articles
    if FoodsoftConfig[:group_order_invoices][:vat_exempt]
      create_vat_exempt_table
    else
      if FoodsoftConfig[:price_markup] > 0
        create_price_markup_table
      else
        create_no_price_markup_table
      end
    end

    move_down 15

    # Small business regulation text if applicable
    if FoodsoftConfig[:group_order_invoices][:vat_exempt]
      text I18n.t('documents.group_order_invoice_pdf.small_business_regulation')
    end

    move_down 10
  end

  private

  def create_vat_exempt_table
    data = []
    data << I18n.t('documents.group_order_invoice_pdf.vat_exempt_rows')

    sum = 0

    @options[:order_articles].each do |id, article|
      next if article[:quantity] == 0

      price = article[:price]
      total_price = article[:total_price]
      sum += total_price

      data << [
        id,
        article[:quantity],
        number_to_currency(price),
        number_to_currency(total_price)
      ]
    end

    data << ["", "", I18n.t('documents.group_order_invoice_pdf.sum_to_pay'), number_to_currency(sum)]

    table(data, width: bounds.width) do
      cells.borders = []
      cells.padding = 3

      # Header row styling
      row(0).borders = [:bottom]
      row(0).font_style = :bold

      # Sum row styling
      row(-1).borders = [:top]
      row(-1).columns(-2..-1).font_style = :bold

      # Align numbers to the right
      columns(1..-1).align = :right
    end
  end

  def create_no_price_markup_table
    data = []
    data << I18n.t('documents.group_order_invoice_pdf.no_price_markup_rows')

    sum_net = 0
    sum_gross = 0

    @options[:order_articles].each do |id, article|
      next if article[:quantity] == 0

      price = article[:price]
      total_price = article[:total_price]
      tax = article[:tax] || FoodsoftConfig[:tax_default]
      tax_factor = tax / 100.0

      price_net = price / (1 + tax_factor)
      total_price_net = total_price / (1 + tax_factor)

      sum_net += total_price_net
      sum_gross += total_price

      data << [
        id,
        article[:quantity],
        number_to_currency(price_net),
        number_to_currency(total_price_net),
        "#{tax}%",
        number_to_currency(total_price)
      ]
    end

    data << ["", "", "", I18n.t('documents.group_order_invoice_pdf.sum_to_pay_net'), "", number_to_currency(sum_net)]
    data << ["", "", "", I18n.t('documents.group_order_invoice_pdf.sum_to_pay_gross'), "", number_to_currency(sum_gross)]

    table(data, width: bounds.width) do
      cells.borders = []
      cells.padding = 3

      # Header row styling
      row(0).borders = [:bottom]
      row(0).font_style = :bold

      # Sum rows styling
      rows(-2..-1).borders = [:top]
      rows(-2..-1).columns(-3..-1).font_style = :bold

      # Align numbers to the right
      columns(1..-1).align = :right
    end
  end

  def create_price_markup_table
    data = []
    data << I18n.t('documents.group_order_invoice_pdf.price_markup_rows')

    sum_net = 0
    sum_gross = 0

    @options[:order_articles].each do |id, article|
      next if article[:quantity] == 0

      price = article[:price]
      total_price = article[:total_price]
      tax = article[:tax] || FoodsoftConfig[:tax_default]
      tax_factor = tax / 100.0

      price_net = price / (1 + tax_factor)
      total_price_net = total_price / (1 + tax_factor)

      sum_net += total_price_net
      sum_gross += total_price

      data << [
        id,
        article[:quantity],
        number_to_currency(price_net),
        number_to_currency(total_price_net),
        "#{tax}%",
        number_to_currency(total_price)
      ]
    end

    data << ["", "", "", I18n.t('documents.group_order_invoice_pdf.sum_to_pay_net'), "", number_to_currency(sum_net)]
    data << ["", "", "", I18n.t('documents.group_order_invoice_pdf.sum_to_pay_gross'), "", number_to_currency(sum_gross)]

    table(data, width: bounds.width) do
      cells.borders = []
      cells.padding = 3

      # Header row styling
      row(0).borders = [:bottom]
      row(0).font_style = :bold

      # Sum rows styling
      rows(-2..-1).borders = [:top]
      rows(-2..-1).columns(-3..-1).font_style = :bold

      # Align numbers to the right
      columns(1..-1).align = :right
    end

    move_down 5
    text I18n.t('documents.group_order_invoice_pdf.markup_included', marge: FoodsoftConfig[:price_markup])
  end
end