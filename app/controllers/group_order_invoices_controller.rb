class GroupOrderInvoicesController < ApplicationController
  include Concerns::SendGroupOrderInvoicePdf

  def show
    @group_order_invoice = GroupOrderInvoice.find(params[:id])
    if FoodsoftConfig[:contact][:tax_number]
      respond_to do |format|
        format.pdf do
          send_group_order_invoice_pdf @group_order_invoice if FoodsoftConfig[:contact][:tax_number]
        end
      end
    else
      raise RecordInvalid
    end
  rescue => error
    redirect_back fallback_location: root_path, notice: 'Something went wrong', alert: I18n.t('errors.general_msg', msg: "#{error} " + I18n.t('errors.check_tax_number'))
  end

  def destroy
    goi = GroupOrderInvoice.find(params[:id])
    @order = goi.group_order.order
    goi.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  def create_multiple
    invoice_date = params[:group_order_invoice][:invoice_date]
    order_id = params[:group_order_invoice][:order_id]
    puts "
    " + "______________" + "
    " + "______________" + "
    " + "______________" + "
    " + "#{invoice_date}" + "
    " + "______________"+ "
    " + "______________"+ "
    " + "______________"
    raise "#{invoice_date}"
    gos = GroupOrder.find_by(order_id: params[:order_id])
    for go in gos
      GroupOrderInvoice.find_or_create_by!(group_order_id: go.id)
      respond_to do |format|
        format.js
      end
    end
    redirect_back fallback_location: root_path
  rescue => error
    redirect_back fallback_location: root_path, notice: 'Something went wrong', :alert => I18n.t('errors.general_msg', :msg => error)
  end

  def create
    go = GroupOrder.find(params[:group_order])
    GroupOrderInvoice.find_or_create_by!(group_order_id: go.id)
    respond_to do |format|
      format.js
    end
    redirect_back fallback_location: root_path
  rescue => error
    redirect_back fallback_location: root_path, notice: 'Something went wrong', :alert => I18n.t('errors.general_msg', :msg => error)
  end
end
