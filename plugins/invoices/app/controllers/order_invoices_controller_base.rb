class OrderInvoicesControllerBase < ApplicationController
  before_action :authenticate_finance

  def toggle_paid
    @invoice = invoice_class.find(params[:id])
    @invoice.paid = !@invoice.paid
    save_and_respond(@invoice)
  end

  protected

  def save_and_respond(record)
    if record.save!
      respond_to { |format| format.js }
    else
      respond_to { |format| format.json { render json: record.errors, status: :unprocessable_entity } }
    end
  end

  def invoice_class
    raise NotImplementedError
  end

  def related_group_order(invoice)
    raise NotImplementedError
  end
end
