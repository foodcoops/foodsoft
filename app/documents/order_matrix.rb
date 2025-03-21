class OrderMatrix < OrderPdf
  HEADER_ROTATE = -30
  PLACEHOLDER_CHAR = 'X'

  def filename
    I18n.t('documents.order_matrix.filename', name: @order.name, date: @order.ends.to_date) + '.pdf'
  end

  def title
    I18n.t('documents.order_matrix.title', name: @order.name,
                                           date: @order.ends.strftime(I18n.t('date.formats.default')))
  end

  def body
    order_articles_data = [[
      OrderArticle.human_attribute_name(:article),
      Article.human_attribute_name(:supplier),
      ArticleVersion.human_attribute_name(:unit_quantity),
      OrderArticle.human_attribute_name(:units_received),
      Article.human_attribute_name(:fc_price_short)
    ]]

    each_order_article do |oa|
      order_articles_data << [oa.article_version.name,
                              oa.article_version.article.supplier.name,
                              oa.article_version.unit_quantity,
                              oa.units,
                              order_article_price_per_unit(oa)]
    end

    order_articles_data.each { |row| row.delete_at 1 } unless @options[:show_supplier]

    name = I18n.t('documents.order_matrix.heading', count: order_articles_data.size - 1)
    nice_table name, order_articles_data do |table|
      if @options[:show_supplier]
        table.column(0).width = bounds.width / 3
        table.column(1).width = bounds.width / 4
      else
        table.column(0).width = bounds.width / 2
      end

      table.columns(-3..-1).align = :right
      table.column(-2).font_style = :bold
    end

    font_size 8

    row_height_1 = height_of(PLACEHOLDER_CHAR) + 3
    col_width_0 = width_of(PLACEHOLDER_CHAR * 20)
    col_width_1 = width_of("#{number_to_currency(888.88)} / #{PLACEHOLDER_CHAR * 4}") + 3
    col_width_2 = width_of(PLACEHOLDER_CHAR * 3) + 5

    first_page = true
    start_new_page(layout: :landscape)
    batch_size = (bounds.width - col_width_0 - col_width_1) / col_width_2
    batch_size = batch_size.floor

    each_ordergroup_batch batch_size do |batch_groups, batch_results|
      start_new_page unless first_page

      header = batch_groups.map do |name, total|
        text = "#{name.try(:truncate, 20)} <b>#{number_to_currency(total)}</b>"
        RotatedCell.new(self, text, inline_format: true, rotate: HEADER_ROTATE)
      end

      rows = [[nil, nil] + header]

      last_supplier_id = -1

      each_order_article do |order_article|
        supplier = order_article.article_version.article.supplier
        if @options[:show_supplier] && last_supplier_id != supplier.id
          row = [make_cell(supplier.name, colspan: 2, font_style: :bold)]
          batch_groups.each { row << nil }
          rows << row
          last_supplier_id = supplier.id
        end

        row = [order_article.article_version.name, order_article_price_per_unit(order_article)]
        row += batch_results[order_article.id] if batch_results[order_article.id]
        rows << row
      end

      table rows, header: true, cell_style: { overflow: :shrink_to_fit } do |table|
        table.cells.padding = [0, 0, 2, 0]
        table.cells.borders = [:left]
        table.cells.border_width = 0.5
        table.cells.border_color = '666666'

        table.row(0).borders = %i[bottom left]
        table.row(0).padding = [2, 0, 2, 0]
        table.row(1..-1).height = row_height_1
        table.column(0..1).borders = []
        table.column(1).align = :right
        table.column(1).padding = [0, 3, 2, 0]
        table.column(2..-1).align = :center
        table.cells[0, 0].borders = []
        table.cells[0, 1].borders = []

        table.column(0).overflow = :truncate
        table.column(0).width = col_width_0
        table.column(1).width = col_width_1
        table.column(2..-1).width = col_width_2

        (0..batch_size).step(5).each do |idx|
          table.column(2 + idx).border_width = 2
        end

        table.row_colors = %w[dddddd ffffff]
      end

      first_page = false
    end
  end
end
