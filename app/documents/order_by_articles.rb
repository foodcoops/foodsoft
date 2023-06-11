# encoding: utf-8
class OrderByArticles < OrderPdf

  def initialize(order, options = {})
    # options[:page_size] = [(595.28 /
    options[:no_header] = true
    options[:no_footer] = true
    super(order, options)
    @supplier_page = {}
    @supplier_page[1] = sorted_order_articles.first.order.supplier
    @title = options[:title]
  end

  def filename
    I18n.t('documents.order_by_articles.filename', :name => order.name, :date => order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_articles.title', :name => order.name,
           :date => order.ends.strftime(I18n.t('date.formats.default')))
  end

  def footer(footer, footer_size)
    font_size FOOTER_FONT_SIZE do
      bounding_box [bounds.left, bounds.bottom - FOOTER_SPACE], width: bounds.width / 2, height: footer_size do
        text footer, align: :left, valign: :bottom if footer
      end
      bounding_box [bounds.left, bounds.bottom - FOOTER_SPACE], width: bounds.width / 2, height: footer_size do
        text I18n.t('lib.render_pdf.page', number: page_number, count: page_count), align: :right, valign: :bottom if footer
      end
    end
  end

  def header(header, header_size)
    header = "#{(@supplier_page[page_number] ? @supplier_page[page_number].name : '')}" + (@title ? " - #{@title}" : '')
    bounding_box [bounds.left, bounds.top + header_size], width: bounds.width / 2, height: header_size do
      text header, size: HEADER_FONT_SIZE, align: :center, overflow: :shrink_to_fit if header
    end
  end

  def nice_table_by_articles(name, footer, data, dimrows = [])
    down_or_page 25
    t = make_table data, width: bounds.width / 2, cell_style: { size: 8, overflow: :shrink_to_fit } do |table|
      # borders
      table.cells.borders = [:bottom]
      table.cells.padding_top = 2
      table.cells.padding_bottom = 4
      table.cells.border_color = 'dddddd'
      table.rows(0).border_color = '666666'

      # dim rows which were ordered but not received
      dimrows.each do |ri|
        table.row(ri).text_color = '999999'
        table.row(ri).columns(0..-1).font_style = nil
      end
      yield table if block_given?
    end
    # start_new_page if (cursor - (t.height + 12 + 5 + 8)).negative?
    start_new_page if (cursor - (t.height + 12)).negative?
    text name, size: 12, style: :bold
    t.draw
    # down_or_page 5
    # text footer, size: 8
  end

  def body
    current_supplier = sorted_order_articles.first.order.supplier
    sorted_order_articles.each do |order_article|
      if current_supplier != order_article.order.supplier
        start_new_page
      end
      current_supplier = order_article.order.supplier
      @supplier_page[page_number] = order_article.order.supplier
      dimrows = []
      rows = [[
                GroupOrderArticle.human_attribute_name(:ordered),
                "#{GroupOrderArticle.human_attribute_name(:received)} (#{order_article.price.unit_quantity * order_article.units})",
                Article.human_attribute_name(:unit),
                GroupOrder.human_attribute_name(:ordergroup),
                GroupOrderArticle.human_attribute_name(:total_price)
              ]]

      each_group_order_article_for_order_article(order_article) do |goa|
        dimrows << rows.length if goa.result == 0
        rows << [group_order_article_quantity_with_tolerance(goa),
                 "____ #{goa.result}",
                 order_article.article.unit,
                 goa.group_order.ordergroup_name,
                 number_to_currency(goa.total_price)]
      end
      next unless rows.length > 1

      # name = "#{order_article.article.name} (#{order_article.article.unit} | #{order_article.price.unit_quantity} | #{number_to_currency(order_article.price.fc_price)})"
      # name += " #{order_article.article.supplier.name}" if @options[:show_supplier]
      name = order_article.article.name
      limit = 34
      trail = 6
      if name.length > limit
        name = name.truncate(limit - trail) + name[-trail..-1]
      end
      name = "#{name} (x #{order_article.units})"
      # footer = "#{I18n.l(Time.now, format: :long)}                #{counter} of #{total}"
      footer = ""
      nice_table_by_articles name, footer, rows, dimrows do |table|
        # table.column(0).width = bounds.width / 2
        # table.columns(1..-1).align = :right
        # table.column(1).font_style = :bold
      end
      # in case table incremented pages, set the supplier again
      @supplier_page[page_number] = order_article.order.supplier
    end
  end

  protected

  def sorted_order_articles
    @sorted_order_articles ||= order_articles
                                 .all
                                 .sort_by { |oa|
                                   name = oa.article.name.gsub(/^\d\d\d\d:\s*/, '')
                                   [oa.order.id, oa.order.supplier.name, name] }
  end
end
