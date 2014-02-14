module OrderArticlesHelper

  def new_order_articles_collection(&block)
    if @order.stockit?
      articles = StockArticle.undeleted.reorder('articles.name')
    else
      articles = @order.supplier.articles.undeleted.reorder('articles.name')
    end
    unless block_given?
      block = Proc.new do |a|
        pkg_info = pkg_helper(a, plain: true)
        a.name + ' ' +
           "(#{a.unit}" +
          (pkg_info.blank? ? '' : " #{pkg_info}") + ")"
      end
    end
    articles.map {|a| block.call(a)}
  end
end
