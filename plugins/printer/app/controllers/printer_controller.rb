class PrinterController < ApplicationController
  include Concerns::SendOrderPdf
  include Tubesock::Hijack

  skip_before_action :authenticate
  before_action :authenticate_printer
  before_action -> { require_plugin_enabled FoodsoftPrinter }

  def socket
    hijack do |tubesock|
      tubesock.onopen do
        tubesock.send_data unfinished_jobs
      end

      tubesock.onmessage do |data|
        update_job data
        tubesock.send_data unfinished_jobs
      end
    end
  end

  def show
    job = PrinterJob.find(params[:id])
    send_order_pdf job.order, job.document
  end

  private

  def unfinished_jobs
    {
      unfinished_jobs: PrinterJob.pending.map(&:id)
    }.to_json
  end

  def update_job(data)
    json = JSON.parse data, symbolize_names: true
    job = PrinterJob.unfinished.find_by_id(json[:id])
    return unless job

    if json[:state]
      job.add_update! json[:state], json[:message]
    end
    job.finish! if json[:finish]
  end

  protected

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  def authenticate_printer
    return head(:unauthorized) unless bearer_token
    return head(:forbidden) if bearer_token != FoodsoftConfig[:printer_token]
  end
end
