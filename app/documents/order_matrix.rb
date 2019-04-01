# encoding: utf-8
class OrderMatrix < OrderPdf

  MAX_ARTICLES_PER_PAGE = 8 # How many order_articles on each page


  def initialize(order, options = {})
    super(order, options)
    @order = Order.find(order[0]) if order.is_a? Array
  end

  def filename
    I18n.t('documents.order_matrix.filename', :name => @order.name, :date => @order.ends.to_date) + '.pdf'
  end

  def title
    @order = Order.find(order[0]) if @order.is_a? Array
    I18n.t('documents.order_matrix.title', :name => @order.name,
           :date => @order.ends.strftime(I18n.t('date.formats.default')),
           :user_name => @order.created_by.name
    )
  end

  def body
    @orders = [@order] unless @orders.is_a? Array

    @orders.each_with_index do |order, _i|
      if order.is_a? Fixnum
        @order = Order.find(order)
      else
        @order = order
      end

      text @order.supplier.name + ' ordered by ' + @order.created_by.name
      move_down 10

      unless @order.note.blank?
        text 'note: ' + @order.note, size: fontsize(9)
        move_down 5
      end

      @order.comments.each_with_index do |comment, i|
        if (i == 0)
          text 'Comments', size: fontsize(9)
          move_down 5
        end
        text comment.user.name + ' wrote: ' + comment.text, size: fontsize(9)
        move_down 5
      end

      move_down 10
    end


    @orders.each_with_index do |order, _i|
      # start_new_page(layout: :landscape) if i > 0

      if order.is_a? Fixnum
        @order = Order.find(order)
      else
        @order = order
      end


      order_articles = @order.order_articles.ordered.sort_by {|o| o.article.name}

      total_num_order_articles = order_articles.size
      page_number = 0
      while page_number * MAX_ARTICLES_PER_PAGE < total_num_order_articles do # Start page generating

        page_number += 1
        start_new_page(layout: :landscape)

        # Collect order_articles for this page
        current_order_articles = order_articles.select do |a|
          order_articles.index(a) >= (page_number - 1) * MAX_ARTICLES_PER_PAGE and
              order_articles.index(a) < page_number * MAX_ARTICLES_PER_PAGE
        end

        # Make order_articles header
        header = [""]
        for header_article in current_order_articles
          name = header_article.article.name.gsub(/[-\/]/, " ").gsub(".", ". ").gsub(/\s+/, ' ')
          name = name.split.collect {|w| w.truncate(8)}.join(" ")
          header << name.truncate(30)
        end

        # Collect group results
        groups_data = [header]

        @order.group_orders.includes(:ordergroup).sort_by(&:ordergroup_name).each do |group_order|

          group_result = [group_order.ordergroup_name.truncate(20)]

          for order_article in current_order_articles
            # get the Ordergroup result for this order_article
            goa = order_article.group_order_articles.where(group_order_id: group_order.id).first
            result = ((goa.nil? || goa.result == 0) ? '' : goa.result.to_i)
            group_result << result
          end
          groups_data << group_result
        end

        group_result = ['Total Units']
        for order_article in current_order_articles
          # get the Ordergroup result for this order_article
          group_result << " #{order_article.units * order_article.price.unit_quantity} X #{order_article.article.unit}"
        end
        groups_data << group_result

        group_result = ['Cases']
        for order_article in current_order_articles
          # get the Ordergroup result for this order_article
          group_result << "#{order_article.units}"
        end
        groups_data << group_result

        groups_data << ['% Spoilage'] + current_order_articles.map {|_a| ''}

        # Make table
        column_widths = [85]
        (MAX_ARTICLES_PER_PAGE + 1).times {|i| column_widths << (656 / (MAX_ARTICLES_PER_PAGE + 1)).floor unless i == 0}
        table groups_data, column_widths: column_widths, cell_style: {size: fontsize(8), overflow: :shrink_to_fit} do |table|
          # table.row(0).style(:size => 6)
          table.cells.border_width = 1
          table.cells.border_color = '666666'
          table.row_colors = ['ffffff', 'ececec']
          table.row(groups_data.length - 1).style(bold: true)
        end

        move_down 10
        text 'Always take a photo if there is any suspicion that produce is spoiled. Include the box/lot code so we can request refunds.'
      end
    end
  end

  private

  # Return price for article.
  #
  # This is a separate method so that plugins can override it.
  #
  # @param article [Article]
  # @return [Number] Price to show
  # @see https://github.com/foodcoops/foodsoft/issues/445
  def article_price(article)
    article.price.fc_price
  end

end
