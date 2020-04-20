# encoding: utf-8
class OrderByArticles < OrderPdf

  def initialize(order, options = {})
    # options[:page_size] = [(595.28 /
    options[:no_header] = true
    options[:no_footer] = true
    super(order, options)
  end

  def filename
    I18n.t('documents.order_by_articles.filename', :name => order.name, :date => order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_articles.title', :name => order.name,
           :date => order.ends.strftime(I18n.t('date.formats.default')))
  end

  def nice_table_by_articles(name, footer, data, dimrows = [])
    down_or_page 25
    t = make_table data, width: bounds.width / 2, cell_style: {size: 8, overflow: :shrink_to_fit} do |table|
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
    start_new_page if (cursor - (t.height + 12 + 5 + 8)).negative?
    text name, size: 12, style: :bold
    t.draw
    down_or_page 5
    text footer, size: 8
  end

  def body
    counter = 0
    total = order_articles.count
    each_order_article do |order_article|
      counter = counter + 1
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
      footer = "#{I18n.l(Time.now, format: :long)}                #{counter} of #{total}"
      nice_table_by_articles name, footer, rows, dimrows do |table|
        # table.column(0).width = bounds.width / 2
        # table.columns(1..-1).align = :right
        # table.column(1).font_style = :bold
      end
    end
  end
end
