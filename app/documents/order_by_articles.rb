# encoding: utf-8
class OrderByArticles < OrderPdf

  # optimal value depends on the average number of ordergroups ordering an article
  #   as well as the available memory
  BATCH_SIZE = 50

  attr_reader :order

  def filename
    I18n.t('documents.order_by_articles.filename', :name => order.name, :date => order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_by_articles.title', :name => order.name,
      :date => order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    each_order_article do |order_article|
      down_or_page

      rows = []
      dimrows = []
      each_group_order_article_for(order_article) do |goa|
        rows << [goa.group_order.ordergroup_name,
                  "#{goa.quantity} + #{goa.tolerance}",
                 goa.result,
                 number_to_currency(goa.total_price(order_article))]
        dimrows << rows.length if goa.result == 0
      end
      next if rows.length == 0
      rows.unshift I18n.t('documents.order_by_articles.rows') # table header

      text "#{order_article.article.name} (#{order_article.article.unit} | #{order_article.price.unit_quantity.to_s} | #{number_to_currency(order_article.price.fc_price)})",
           style: :bold, size: fontsize(10)
      table rows, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
        table.column(0).width = 200
        table.columns(1..3).align = :right
        table.column(2).font_style = :bold
        table.cells.border_width = 1
        table.cells.border_color = '666666'
        table.rows(0).border_bottom_width = 2
        # dim rows which were ordered but not received
        dimrows.each do |ri|
          table.row(ri).text_color = '999999'
          table.row(ri).columns(0..-1).font_style = nil
        end
      end
    end
  end

  private

  def order_articles
    order.order_articles.ordered.
      joins(:article).
      preload(:article_price). # don't join but preload article_price, just in case it went missing
      preload(:group_order_articles => {:group_order => :ordergroup})
  end

  def each_order_article
    order_articles.find_each_with_order(batch_size: BATCH_SIZE) {|oa| yield oa }
  end

  def group_order_articles_for(order_article)
    goas = order_article.group_order_articles.to_a
    goas.sort_by! {|goa| goa.group_order.ordergroup_name }
    goas
  end

  def each_group_order_article_for(group_order)
    group_order_articles_for(group_order).each {|goa| yield goa }
  end

end
