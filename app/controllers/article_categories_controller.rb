class ArticleCategoriesController < ApplicationController

  inherit_resources # Build default REST Actions via plugin

  before_filter :authenticate_article_meta

  def create
    create!(:notice => I18n.t('article_categories.create.notice')) { article_categories_path }
  end

  def update
    update!(:notice => I18n.t('article_categories.update.notice')) { article_categories_path }
  end

  def destroy
    destroy!
  rescue => error
    redirect_to article_categories_path, alert: I18n.t('article_categories.destroy.error', message: error.message)
  end

  protected

  def collection
    @article_categories = ArticleCategory.order('name')
  end

end
