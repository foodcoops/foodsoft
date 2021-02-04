# encoding: utf-8
class OrderFax < OrderPdf

  BATCH_SIZE = 250

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
      unless order.supplier.try(:fax).blank?
        move_down 5
        text "#{Supplier.human_attribute_name :fax}: #{order.supplier[:fax]}"
      end
    end

    move_down 5
    text Date.today.strftime(I18n.t('date.formats.default')), align: :right

    move_down 10
    text "#{Delivery.human_attribute_name :date}:"
    move_down 10
    unless order.supplier.try(:contact_person).blank?
      text "#{Supplier.human_attribute_name :contact_person}: #{order.supplier[:contact_person]}"
      move_down 10
    end

    # Articles
    total = 0
    data = [I18n.t('documents.order_fax.rows')]
    each_order_article do |oa|
      subtotal = oa.units_to_order * oa.price.unit_quantity * oa.price.price
      total += subtotal
      data << [oa.article.order_number,
               oa.units_to_order,
               oa.article.name,
               oa.price.unit_quantity,
               oa.article.unit,
               number_to_currency(oa.price.price),
               number_to_currency(subtotal)]
    end
    data << [I18n.t('documents.order_fax.total'), nil, nil, nil, nil, nil, number_to_currency(total)]
    table data, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
      table.header = true
      table.cells.border_width = 1
      table.cells.border_color = '666666'

      table.row(0).border_bottom_width = 2
      table.columns(1).align = :right
      table.columns(3..6).align = :right
      table.row(data.length-1).columns(0..5).borders = [:top, :bottom]
      table.row(data.length-1).columns(0).borders = [:top, :bottom, :left]
      table.row(data.length-1).border_top_width = 2
    end
              #font_size: fontsize(8),
              #vertical_padding: 3,
              #border_style: :grid,
              #headers: ["BestellNr.", "Menge","Name", "Gebinde", "Einheit","Preis/Einheit"],
              #align: {0 => :left}
  end

  private

  def order_articles
    order.order_articles.ordered.
      joins(:article).
      order('articles.order_number').order('articles.name').
      preload(:article, :article_price)
  end

  def each_order_article
    order_articles.find_each_with_order(batch_size: BATCH_SIZE) {|oa| yield oa }
  end

end
