# encoding: utf-8
class OrderFax < OrderPdf

  def filename
    I18n.t('documents.order_fax.filename', :name => @order.name, :date => @order.ends.to_date) + '.pdf'
  end

  def title
    false
  end

  def body
    contact = FoodsoftConfig[:contact].symbolize_keys

    # From paragraph
    bounding_box [margin_box.right-200,margin_box.top], width: 200 do
      text FoodsoftConfig[:name], size: 9, align: :right
      move_down 5
      text contact[:street], size: 9, align: :right
      move_down 5
      text "#{contact[:zip_code]} #{contact[:city]}", size: 9, align: :right
      move_down 5
      text "#{I18n.t('simple_form.labels.supplier.customer_number')}: #{@order.supplier.try(:customer_number)}", size: 9, align: :right
      move_down 5
      text "#{I18n.t('simple_form.labels.supplier.phone')}: #{contact[:phone]}", size: 9, align: :right
      move_down 5
      text "#{I18n.t('simple_form.labels.supplier.email')}: #{contact[:email]}", size: 9, align: :right
    end

    # Recipient
    bounding_box [margin_box.left,margin_box.top-60], width: 200 do
      text @order.name
      move_down 5
      text @order.supplier.try(:address).to_s
      move_down 5
      text "#{I18n.t('simple_form.labels.supplier.fax')}: #{@order.supplier.try(:fax)}"
    end

    move_down 5
    text Date.today.strftime(I18n.t('date.formats.default')), align: :right

    move_down 10
    text "#{I18n.t('simple_form.labels.delivery.delivered_on')}:"
    move_down 10
    text "#{I18n.t('simple_form.labels.supplier.contact_person')}: #{@order.supplier.try(:contact_person)}"
    move_down 10

    # Articles
    data = [I18n.t('documents.order_fax.rows')]
    data = @order.order_articles.ordered.all(include: :article).collect do |a|
      [a.article.order_number,
       a.units_to_order,
       a.article.name,
       a.price.unit_quantity,
       a.article.unit,
       a.price.price]
    end
    table data, cell_style: {size: 8, overflow: :shrink_to_fit} do |table|
      table.cells.border_width = 1
      table.cells.border_color = '666666'

      table.columns(1).align = :right
      table.columns(3..5).align = :right
    end
              #font_size: 8,
              #vertical_padding: 3,
              #border_style: :grid,
              #headers: ["BestellNr.", "Menge","Name", "Gebinde", "Einheit","Preis/Einheit"],
              #align: {0 => :left}
  end

end
