class PickupsController < ApplicationController

  def index
    @orders = Order.order('pickup DESC').group_by { |o| o.pickup }
  end

  def document
    return redirect_to pickups_path, alert: t('.empty_selection') unless params[:orders]

    order_ids = params[:orders].map(&:to_i)

    if params[:articles_pdf]
      klass = OrderByArticles
    elsif params[:groups_pdf]
      klass = OrderByGroups
    elsif params[:matrix_pdf]
      klass = OrderMatrix
    end

    return redirect_to pickups_path, alert: t('.invalid_document') unless klass

    pdf = klass.new(order_ids, title: t('.title'), show_supplier: true)

    send_data pdf.to_pdf, type: 'application/pdf', disposition: :inline
  end
end
