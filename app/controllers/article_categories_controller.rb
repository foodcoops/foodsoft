class ArticleCategoriesController < ApplicationController

  before_filter :authenticate_article_meta

  def index
    @article_categories = ArticleCategory.all :order => 'name'
  end

  def new
    @article_category = ArticleCategory.new

    render :update do |page|
      page['category_form'].replace_html :partial => 'article_categories/form'
      page['category_form'].show
    end
  end

  def edit
    @article_category = ArticleCategory.find(params[:id])

    render :update do |page|
      page['category_form'].replace_html :partial => 'article_categories/form'
      page['category_form'].show
    end
  end

  def create
    @article_category = ArticleCategory.new(params[:article_category])

    if @article_category.save
      render :update do |page|
       page['category_form'].hide
       page['category_list'].replace_html :partial => 'article_categories/list'
       page['category_'+@article_category.id.to_s].visual_effect(:highlight,
                                                                  :duration => 2)
      end
    else
      render :update do |page|
        page['category_form'].replace_html :partial => 'article_categories/form'
      end
    end
  end

  def update
    @article_category = ArticleCategory.find(params[:id])

    if @article_category.update_attributes(params[:article_category])
      render :update do |page|
       page['category_form'].hide
       page['category_list'].replace_html :partial => 'article_categories/list'
       page['category_'+@article_category.id.to_s].visual_effect(:highlight,
                                                                  :duration => 2)
      end
    else
      render :update do |page|
        page['category_form'].replace_html :partial => 'article_categories/form'
      end
    end
  end

  def destroy
    @article_category = ArticleCategory.find(params[:id])
    @article_category.destroy

    #id = @article_category.id.to_s #save the id before destroying the object
    if @article_category.destroy
      render :update do |page|
        page['category_'+@article_category.id].visual_effect :drop_out
      end
    end
  end
end
