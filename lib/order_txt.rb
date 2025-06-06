class OrderTxt
  include ActionView::Helpers::NumberHelper
  include ArticlesHelper
  include OrdersHelper

  def initialize(order, _options = {})
    @order = order
  end

  # Renders the fax-text-file
  # e.g. for easier use with online-fax-software, which don't accept pdf-files
  def to_txt
    supplier = @order.supplier
    contact = FoodsoftConfig[:contact].symbolize_keys
    text = I18n.t('orders.fax.heading', name: FoodsoftConfig[:name])
    text += "\n#{Supplier.human_attribute_name(:customer_number)}: #{supplier.customer_number}" if supplier.customer_number.present?
    text += "\n" + I18n.t('orders.fax.delivery_day')
    text += "\n\n#{supplier.name}\n#{supplier.address}\n#{Supplier.human_attribute_name(:fax)}: #{supplier.fax}\n\n"
    text += '****** ' + I18n.t('orders.fax.to_address') + "\n\n"
    text += "#{FoodsoftConfig[:name]}\n#{contact[:street]}\n#{contact[:zip_code]} #{contact[:city]}\n\n"
    text += '****** ' + I18n.t('orders.fax.articles') + "\n\n"

    # prepare order_articles data
    order_articles = @order.order_articles.ordered.includes(:article_version).order('article_versions.order_number ASC, article_versions.name ASC')
    any_number_present = order_articles.where.not(article_version: { order_number: nil }).any?

    order_headers = {
      number: any_number_present ? { label: I18n.t('orders.fax.number') } : nil,
      amount: { label: I18n.t('orders.fax.amount'), align: :right },
      unit: { label: I18n.t('orders.fax.unit') },
      name: { label: I18n.t('orders.fax.name') }
    }.compact

    order_positions = order_articles.map do |oa|
      number = oa.article_version.order_number || ''
      amount = format_units_to_order(oa).to_s
      unit = format_supplier_order_unit_with_ratios(oa.price)
      {
        number: number,
        amount: amount,
        unit: unit,
        name: oa.article_version.name
      }
    end

    text += text_table(order_headers, order_positions)
    text
  end

  private

  def text_table(headers, rows)
    table_keys = headers.keys
    columns = table_keys.each_with_index.map do |key, index|
      header = headers[key]
      label = header[:label]
      {
        key: key,
        label: label,
        align: header[:align],
        characters: index + 1 < table_keys.length ? (rows.pluck(key) + [label]).map(&:length).max : nil
      }
    end

    header_txt = columns.map { |column| align_text_column(column[:label], column[:characters], column[:align]) }.join(' ')

    rows_texts = rows.map do |row|
      columns.map { |column| align_text_column(row[column[:key]], column[:characters], column[:align]) }.join(' ')
    end

    ([header_txt] + rows_texts).join("\n")
  end

  def align_text_column(text, characters, align)
    return text if characters.nil?

    align == :right ? text.rjust(characters) : text.ljust(characters)
  end
end
