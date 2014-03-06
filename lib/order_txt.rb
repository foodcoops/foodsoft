
class OrderTxt
  def initialize(order, options={})
    @order = order
  end

  # Renders the fax-text-file
  # e.g. for easier use with online-fax-software, which don't accept pdf-files
  def to_txt
    supplier = @order.supplier
    contact = FoodsoftConfig[:contact].symbolize_keys
    text = I18n.t('orders.fax.heading', :name => FoodsoftConfig[:name])
    text += "\n#{Supplier.human_attribute_name(:customer_number)}: #{supplier.customer_number}" unless supplier.customer_number.blank?
    text += "\n" + I18n.t('orders.fax.delivery_day')
    text += "\n\n#{supplier.name}\n#{supplier.address}\n#{Supplier.human_attribute_name(:fax)}: #{supplier.fax}\n\n"
    text += "****** " + I18n.t('orders.fax.to_address') + "\n\n"
    text += "#{FoodsoftConfig[:name]}\n#{contact[:street]}\n#{contact[:zip_code]} #{contact[:city]}\n\n"
    text += "****** " + I18n.t('orders.fax.articles') + "\n\n"
    text += I18n.t('orders.fax.number') + "   " + I18n.t('orders.fax.amount') + "   " + I18n.t('orders.fax.name') + "\n"
    # now display all ordered articles
    @order.order_articles.ordered.includes([:article, :article_price]).each do |oa|
      number = oa.article.order_number
      (8 - number.size).times { number += " " }
      quantity = oa.units_to_order.to_i.to_s
      quantity = " " + quantity if quantity.size < 2
      text += "#{number}   #{quantity}    #{oa.article.name}\n"
    end
    text
  end

  # Helper method to test pdf via rails console: OrderTxt.new(order).save_tmp
  def save_tmp
    File.open("#{Rails.root}/tmp/#{self.class.to_s.underscore}.txt", 'w') {|f| f.write(to_csv.force_encoding("UTF-8")) }
  end
end
