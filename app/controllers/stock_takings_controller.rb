class StockTakingsController < ApplicationController
  inherit_resources

  def index
    @stock_takings = StockTaking.order('date DESC').page(params[:page]).per(@per_page)
  end

  def new
    @stock_taking = StockTaking.new
    StockArticle.undeleted.each { |a| @stock_taking.stock_changes.build(:stock_article => a) }
  end

  def create
    create!(:notice => I18n.t('stock_takings.create.notice'))
  end

  def update
    update!(:notice => I18n.t('stock_takings.update.notice'))
  end

  def fill_new_stock_article_form
    article = Article.find(params[:article_id])
    supplier = article.supplier
    stock_article = supplier.stock_articles.build(
      article.attributes.reject { |attr| attr == ('id' || 'type')}
    )

    render :partial => 'stock_article_form', :locals => {:stock_article => stock_article}
  end
  
  def add_stock_article
    article = StockArticle.new(params[:stock_article])
    render :update do |page|
      if article.save
        page.insert_html :top, 'stock_changes', :partial => 'stock_change',
          :locals => {:stock_change => article.stock_changes.build}

        page.replace_html 'new_stock_article', :partial => 'stock_article_form',
          :locals => {:stock_article => StockArticle.new}
      else
        page.replace_html 'new_stock_article', :partial => 'stock_article_form',
          :locals => {:stock_article => article}
      end
    end
  end

  def drop_stock_change
    stock_change = StockChange.find(params[:stock_change_id])
    stock_change.destroy

    render :update do |page|
      page.visual_effect :DropOut, "stock_change_#{stock_change.id}"
    end
  end
end
