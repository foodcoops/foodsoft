class OrderCommentsController < ApplicationController
  def new
    @order = Order.find(params[:order_id])
    @order_comment = @order.comments.build(:user => current_user)
  end

  def create
    @order_comment = OrderComment.new(params[:order_comment])
    if @order_comment.save
      render :layout => false
    else
      render :action => :new, :layout => false
    end
  end
end
