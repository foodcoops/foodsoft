# encoding: utf-8
class OrderFax < OrderPdf

  def filename
    "Bestellung #{@order.name}-#{@order.ends.to_date} - Fax.pdf"
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
      text "Kundennummer: #{@order.supplier.try(:customer_number)}", size: 9, align: :right
      move_down 5
      text "Telefon: #{contact[:phone]}", size: 9, align: :right
      move_down 5
      text "E-mail: #{contact[:email]}", size: 9, align: :right
    end

    # Recipient
    bounding_box [margin_box.left,margin_box.top-60], width: 200 do
      text @order.name
      move_down 5
      text @order.supplier.try(:address).to_s
      move_down 5
      text "Fax: #{@order.supplier.try(:fax)}"
    end

    move_down 5
    text Date.today.strftime('%d.%m.%Y'), align: :right

    move_down 10
    text "Lieferdatum:"
    move_down 10
    text "Ansprechpartner: #{@order.supplier.try(:contact_person)}"
    move_down 10

    # Articles
    data = [["BestellNr.", "Menge","Name", "Gebinde", "Einheit","Preis/Einheit"]]
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
