class Finance::GroupOrderArticlesController < ApplicationController

  before_filter :authenticate_finance

  layout false  # We only use this controller to server js snippets, no need for layout rendering

  def new
    @order_article = OrderArticle.find(params[:order_article_id])
    @group_order_article = GroupOrderArticle.new(order_article: @order_article)
  end

  def create
    @group_order_article = GroupOrderArticle.new(params[:group_order_article])
    @order_article = @group_order_article.order_article

    # As we hide group_order_articles with a result of 0, we should not complain, when an existing group_order_article is found
    goa = GroupOrderArticle.where(group_order_id: @group_order_article.group_order_id,
                                  order_article_id: @order_article.id).first

    if goa and goa.update_attributes(params[:group_order_article])
      @group_order_article = goa

      update_summaries(@group_order_article)
      render :update

    elsif @group_order_article.save
      update_summaries(@group_order_article)
      render :update

    else  # Validation failed, show form
      render :new
    end
  end

  def edit
    @group_order_article = GroupOrderArticle.find(params[:id])
    @order_article = @group_order_article.order_article
  end

  def update
    @group_order_article = GroupOrderArticle.find(params[:id])
    @order_article = @group_order_article.order_article

    if @group_order_article.update_attributes(params[:group_order_article])
      update_summaries(@group_order_article)
    else
      render :edit
    end
  end

  def update_result
    group_order_article = GroupOrderArticle.find(params[:id])
    @order_article = group_order_article.order_article

    if params[:modifier] == '-'
      group_order_article.update_attribute :result, group_order_article.result - 1
    elsif params[:modifier] == '+'
      group_order_article.update_attribute :result, group_order_article.result + 1
    end

    update_summaries(group_order_article)

    render :update
  end

  def destroy
    group_order_article = GroupOrderArticle.find(params[:id])
    group_order_article.destroy
    update_summaries(group_order_article)
    @order_article = group_order_article.order_article

    render :update
  end

  protected

  def update_summaries(group_order_article)
    # Update the price attribute of new GroupOrder
    group_order_article.group_order.update_price!
    # Update units_to_order of order_article
    group_order_article.order_article.update_results! if group_order_article.order_article.article.is_a?(StockArticle)
  end
end
