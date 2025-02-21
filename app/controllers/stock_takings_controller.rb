class StockTakingsController < ApplicationController
  inherit_resources

  def index
    @stock_takings = StockTaking.order('date DESC').page(params[:page]).per(@per_page)
  end

  def new
    @stock_taking = StockTaking.new
    StockArticle.with_latest_versions_and_categories.undeleted.each do |a|
      @stock_taking.stock_changes.build(stock_article: a)
    end
  end

  def new_on_stock_article_create # See publish/subscribe design pattern in /doc.
    stock_article = StockArticle.find(params[:stock_article_id])
    @stock_change = StockChange.new(stock_article: stock_article)

    render layout: false
  end

  def create
    create!(notice: I18n.t('stock_takings.create.notice'))
  end

  def update
    update!(notice: I18n.t('stock_takings.update.notice'))
  end
end
