# Get ActiveRecord objects
contact = FoodsoftConfig[:contact].symbolize_keys

# Define header and footer
#pdf.header [pdf.margin_box.left,pdf.margin_box.top+30] do
#  pdf.text title, :size => 10, :align => :center
#end
pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom-5] do
  pdf.stroke_horizontal_rule
  pdf.text "Seite #{pdf.page_count}", :size => 8
end

# From paragraph
pdf.bounding_box [pdf.margin_box.right-200,pdf.margin_box.top], :width => 200 do
  pdf.text FoodsoftConfig[:name], :align => :right
  pdf.move_down 5
  pdf.text contact[:street], :align => :right
  pdf.move_down 5
  pdf.text contact[:zip_code] + " " + contact[:city], :align => :right
  pdf.move_down 10
  pdf.text contact[:phone], :size => 9, :align => :right
  pdf.move_down 5
  pdf.text contact[:email], :size => 9, :align => :right
end

# Recipient
pdf.bounding_box [pdf.margin_box.left,pdf.margin_box.top-60], :width => 200 do
  pdf.text @order.name
  pdf.move_down 5
  pdf.text @order.supplier.address
  pdf.move_down 5
  pdf.text "Fax: " + @order.supplier.fax
end

pdf.text Date.today.strftime('%d.%m.%Y'), :align => :right

pdf.move_down 10
pdf.text "Lieferdatum:"
pdf.move_down 10
pdf.text "Ansprechpartner: " + @order.supplier.contact_person
pdf.move_down 10

# Articles
data = @order.order_articles.ordered.all(:include => :article).collect do |a|
  [a.article.order_number, a.units_to_order, a.article.name,
   a.price.unit_quantity, a.article.unit, a.price.price]
end
pdf.table data,
  :font_size => 8,
  :vertical_padding => 3,
  :border_style => :grid,
  :headers => ["BestellNr.", "Menge","Name", "Gebinde", "Einheit","Preis/Einheit"],
  :align => {0 => :left}