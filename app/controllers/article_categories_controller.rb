class ArticleCategoriesController < ApplicationController
  inherit_resources # Build default REST Actions via plugin

  before_action :authenticate_article_meta

  def create
    create!(notice: I18n.t('article_categories.create.notice')) { article_categories_path }
  end

  def update
    update!(notice: I18n.t('article_categories.update.notice')) { article_categories_path }
  end

  def destroy
    resource.mark_as_deleted
    redirect_to article_categories_path, notice: I18n.t('flash.actions.destroy.notice', resource_name: resource.class.model_name.human)
  rescue StandardError => e
    redirect_to article_categories_path, alert: I18n.t('article_categories.destroy.error', message: e.message)
  end

  protected

  def collection
    @article_categories = ArticleCategory.undeleted.order('name')
  end
end
