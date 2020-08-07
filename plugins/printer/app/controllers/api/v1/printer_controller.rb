class Api::V1::PrinterController < Api::V1::BaseController
  include Concerns::SendOrderPdf
  before_action -> { require_plugin_enabled FoodsoftPrinter }

  def show
    job = PrinterJob.find(params[:id])
    send_order_pdf job.order, job.document
  end
end
