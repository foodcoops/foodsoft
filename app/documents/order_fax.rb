# encoding: utf-8
class OrderFax < OrderPdf

  BATCH_SIZE = 250

  attr_reader :order

  def filename
    I18n.t('documents.order_fax.filename', :name => order.name, :date => order.ends.to_date) + '.pdf'
  end

  def title
    false
  end

  def body
    contact = FoodsoftConfig[:contact].symbolize_keys

    # From paragraph
    bounding_box [margin_box.right-200,margin_box.top], width: 200 do
      text FoodsoftConfig[:name], size: fontsize(9), align: :right
      move_down 5
      text contact[:street], size: fontsize(9), align: :right
      move_down 5
      text "#{contact[:zip_code]} #{contact[:city]}", size: fontsize(9), align: :right
      move_down 5
      text "Order Contact: #{@order.created_by.name}", size: fontsize(9), align: :right
      move_down 5

      unless order.supplier.try(:customer_number).blank?
        text "#{Supplier.human_attribute_name :customer_number}: #{order.supplier[:customer_number]}", size: fontsize(9), align: :right
        move_down 5
      end
      unless contact[:phone].blank?
        text "#{Supplier.human_attribute_name :phone}: #{contact[:phone]}", size: fontsize(9), align: :right
        move_down 5
      end
      unless contact[:email].blank?
        text "#{Supplier.human_attribute_name :email}: #{contact[:email]}", size: fontsize(9), align: :right
      end
    end

    # Recipient
    bounding_box [margin_box.left,margin_box.top-60], width: 200 do
      text order.name
      move_down 5
      text order.supplier.try(:address).to_s
      unless order.supplier.try(:phone).blank?
        move_down 5
        text "#{Supplier.human_attribute_name :phone}: #{order.supplier[:phone]}"
      end
      unless order.supplier.try(:fax).blank?
        move_down 5
        text "#{Supplier.human_attribute_name :fax}: #{order.supplier[:fax]}"
      end
    end

    move_down 5
    text I18n.t('documents.order_fax.ordered_on', date: order.ends.strftime(I18n.t('date.formats.long'))), align: :right
    unless order.pickup.nil?
      move_down 5
      text I18n.t('documents.order_fax.deliver_on', date: order.pickup.strftime(I18n.t('date.formats.long'))), align: :right
    end
    move_down 10
    unless order.supplier.try(:contact_person).blank?
      text "#{Supplier.human_attribute_name :contact_person}: #{order.supplier[:contact_person]}"
      move_down 10
    end

    # Articles
    data, total = table_data

    column_widths=[30, 40, 90, 40, 210, 60, 70]
    data << [nil, nil, nil, nil, nil, I18n.t('documents.order_fax.total'), number_to_currency(total)]
    table data, column_widths: column_widths, cell_style: {size: fontsize(8), font: 'Courier', overflow: :shrink_to_fit} do |table|
      table.header = true
      # table.cells.border_width = 1
      table.cells.border_color = '666666'
      table.cells.borders = [:bottom]

      table.row(0).border_bottom_width = 2
      table.columns(0..6).align = :right
      # table.columns(2).align = :right
      table.columns(4).align = :left
      # table.columns(5).align = :left
      table.row(0).columns(3).align = :center
      # table.columns(3..6).align = :right
      table.row(data.length-1).columns(0..6).borders = [:top, :bottom]
      table.row(data.length-1).columns(0).borders = [:top, :bottom]
      table.row(data.length-1).border_top_width = 2
    end
    #font_size: fontsize(8),
    #vertical_padding: 3,
    #border_style: :grid,
    #headers: ["BestellNr.", "Menge","Name", "Gebinde", "Einheit","Preis/Einheit"],
    #align: {0 => :left}
  end

  def table_data
    total = 0
    data = [I18n.t('documents.order_fax.rows')]
    each_order_article do |oa|
      #subtotal = oa.units_to_order * oa.price.unit_quantity * oa.price.price

      price = oa.price
      units_to_order = oa.units
      supplier_price = price.supplier_price || oa.article.price

      begin
        unit = Unit.new(oa.article.unit) rescue Unit.new(oa.article.unit.downcase)
        total_quantity = units_to_order * oa.price.unit_quantity #* unit.scalar
        unit = unit #.units

        if (unit.scalar == 1)
          unit = unit.units
        else
          unit = "X #{unit}"
        end
        unit = unit.to_s.upcase
      rescue
        unit = oa.article.unit
        total_quantity = units_to_order * oa.price.unit_quantity
      end

      subtotal = units_to_order * supplier_price
      total += subtotal

      data << [(oa.article.order_number.length < 10 ? oa.article.order_number.sub('PRO-', '') : ''),
               units_to_order,
               "#{total_quantity} #{unit}",
               oa.article.origin,
               [oa.article.name.squeeze(' '), "\n", oa.article.manufacturer].join(''),
               number_to_currency(oa.price.supplier_price),
               number_to_currency(subtotal)]

      #if there is a deposit, show it as a line item
      # if (oa.price.deposit > 0)
      #   total_deposit = oa.units_to_order * oa.price.unit_quantity * oa.price.deposit
      #   total += total_deposit
      #   data << ['',
      #            '',
      #            'deposit',
      #            '', #'', #oa.price.unit_quantity,
      #            '',
      #            number_to_currency(oa.price.deposit),
      #            number_to_currency(total_deposit)]
      # end
    end
    return data, total
  end

  private

  def order_articles
    order.order_articles.ordered.
        joins(:article).
        order('articles.name').
        order('articles.order_number').
        preload(:article, :article_price)
  end

  def each_order_article
    order_articles
        .find_each_with_order(batch_size: BATCH_SIZE) do |oa|
      yield oa if oa.units>0
    end

  end

end
