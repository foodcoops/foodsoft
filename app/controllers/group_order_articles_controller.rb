class GroupOrderArticlesController < ApplicationController

  before_filter :authenticate_finance
  before_filter :find_group_order_article, except: [:new, :create]

  layout false  # We only use this controller to server js snippets, no need for layout rendering

  def new
    @order_article = OrderArticle.find(params[:order_article_id])
    @group_order_article = GroupOrderArticle.new(order_article: @order_article)
  end

  def create
    # XXX when ordergroup_id appears before order_article_id in the parameters, you
    #     can get `NoMethodError - undefined method 'order_id' for nil:NilClass`
    @group_order_article = GroupOrderArticle.new(params[:group_order_article])
    @order_article = @group_order_article.order_article

    # As we hide group_order_articles with a result of 0, we should not complain, when an existing group_order_article is found
    goa = GroupOrderArticle.where(group_order_id: @group_order_article.group_order_id,
                                  order_article_id: @order_article.id).first

    if goa and goa.update_attributes(params[:group_order_article])
      @group_order_article = goa

      update_summaries(@group_order_article)
      render :create

    elsif @group_order_article.save
      update_summaries(@group_order_article)
      render :create

    else  # Validation failed, show form
      render :new
    end
  end

  def update
    if params[:delta]
      @group_order_article.update_attribute :result, [@group_order_article.result + params[:delta].to_f, 0].max
    else
      @group_order_article.update_attributes(params[:group_order_article])
    end

    update_summaries(@group_order_article)

    render :update
  end

  def destroy
    # only destroy if quantity and tolerance was zero already, so that we don't
    # lose what the user ordered, if any
    if @group_order_article.quantity > 0 or @group_order_article.tolerance >0
      @group_order_article.update_attribute(:result, 0)
    else
      @group_order_article.destroy
    end
    update_summaries(@group_order_article)

    render :update
  end

  protected

  def update_summaries(group_order_article)
    # Update the price attribute of new GroupOrder
    group_order_article.group_order.update_price!
    # Update units_to_order of order_article
    group_order_article.order_article.update_results! if group_order_article.order_article.article.is_a?(StockArticle)
  end

  def find_group_order_article
    @group_order_article = GroupOrderArticle.find(params[:id])
  end
end
