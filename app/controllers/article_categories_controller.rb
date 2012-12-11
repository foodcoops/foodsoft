class ArticleCategoriesController < ApplicationController

  inherit_resources # Build default REST Actions via plugin

  before_filter :authenticate_article_meta

  def create
    create!(:notice => "Die Kategorie wurde gespeichert") { article_categories_path }
  end

  def update
    update!(:notice => "Die Kategorie wurde aktualisiert") { article_categories_path }
  end

  def destroy
    destroy!
  rescue => error
    redirect_to article_categories_path, alert: t('controller.article_categories.destroy.error', message: error.message)
  end

  protected

  def collection
    @article_categories = ArticleCategory.order('name')
  end

end
