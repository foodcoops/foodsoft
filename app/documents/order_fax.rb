# encoding: utf-8
class OrderFax < OrderPdf

  def filename
    I18n.t('documents.order_fax.filename', foodcoop: FoodsoftConfig[:name], supplier: @order.name, date: @order.ends.to_date) + '.pdf'
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
      unless @order.supplier.try(:customer_number).blank?
        text "#{Supplier.human_attribute_name :customer_number}: #{@order.supplier[:customer_number]}", size: fontsize(9), align: :right
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
      text @order.name
      move_down 5
      text @order.supplier.try(:address).to_s
      unless @order.supplier.try(:fax).blank?
        move_down 5
        text "#{Supplier.human_attribute_name :fax}: #{@order.supplier[:fax]}"
      end
    end

    text I18n.t('documents.order_fax.date', date: Date.today.strftime(I18n.t('date.formats.default'))), align: :right, size: fontsize(9)
    move_down 5

    if (contact_person = @order.supplier.try(:contact_person)).present?
      text "#{Supplier.human_attribute_name :contact_person}: #{contact_person}"
      move_down 10
    end

    # Articles
    total_net = total_deposit = total_tax = total_gross = 0
    data = [[
      Article.human_attribute_name(:order_number_short),
      Article.human_attribute_name(:name),
      Article.human_attribute_name(:unit),
      {image: "#{Rails.root}/app/assets/images/package-bg.png", scale: 0.6, position: :center},
      nil,
      I18n.t('documents.order_fax.price'),
      Article.human_attribute_name(:deposit),
      Article.human_attribute_name(:tax),
      OrderArticle.human_attribute_name(:units_to_order_short),
      I18n.t('documents.order_fax.subtotal')]]
    data += @order.order_articles.ordered.includes(:article).order('articles.order_number, articles.name').collect do |a|
      subtotal = a.units_to_order * a.price.unit_quantity * a.price.price
      total_net += subtotal
      total_deposit += a.units_to_order * a.price.unit_quantity * a.price.deposit
      total_tax += a.units_to_order * a.price.unit_quantity * a.price.tax_price
      total_gross += a.units_to_order * a.price.unit_quantity * a.price.gross_price
      [a.article.order_number,
       a.article.name,
       a.article.unit,
       a.article.unit_quantity > 1 ? "× #{a.article.unit_quantity}" : nil,
       a.article.unit_quantity > 1 && (pu=a.article.pack_unit) ? "= #{pu}" : nil,
       number_to_currency(a.price.price * a.article.unit_quantity),
       a.price.deposit != 0 ? number_to_currency(a.price.deposit * a.article.unit_quantity) : nil,
       number_to_percentage(a.price.tax),
       a.units_to_order,
       number_to_currency(subtotal)]
    end

    # Hide columns if no data is present by making the header empty
    [0, 3, 4, 6, 7].each do |col|
      data[0][col] = nil unless data[1..-1].select {|r| r[col].present?}.any?
    end

    foot = []
    foot << [{colspan: 9, content: I18n.t('documents.order_fax.total_net')}, number_to_currency(total_net)]
    foot << [{colspan: 9, content: Article.human_attribute_name(:deposit)}, number_to_currency(total_deposit)] if total_deposit > 0
    foot << [{colspan: 9, content: Article.human_attribute_name(:tax)}, number_to_currency(total_tax)] if total_tax > 0
    foot << [{colspan: 9, content: I18n.t('documents.order_fax.total_gross')}, number_to_currency(total_gross)] if total_gross != total_net

    table data+foot, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do
      cells.borders        = [:bottom]
      cells.border_width   = 0.02
      cells.border_color   = 'dddddd'

      header = true
      rows(0).border_width   = 1
      rows(0).border_color   = '666666'
      rows(0).font_style     = :bold
      row(-foot.count).borders      = [:top]
      row(-foot.count).border_width = 1
      row(-foot.count).border_color = '666666'
      row(-foot.count).font_style   = :bold
      row(-1).font_style            = :bold
      rows((-foot.count+1)..-1).borders     = [] unless foot.count==1
      rows((-foot.count+2)..-1).padding_top = 0 unless foot.count==1

      columns(2).align         = :right
      columns(2).padding_right = 0
      columns(3).padding_left  = 0
      columns(3).align         = :center
      columns(3).padding_right = 2
      columns(4).padding_left  = 0
      columns(8).font_style    = :bold
      columns(8).align         = :center
      columns(8).rows(0..(-foot.count-1)).background_color = 'eeeeee'
      columns(5..6).align      = :right
      columns(-1).align        = :right
    end
  end

end
