class PrinterJobsController < ApplicationController
  include Concerns::SendOrderPdf

  before_action -> { require_plugin_enabled FoodsoftPrinter }

  def index
    jobs = PrinterJob.includes(:printer_job_updates)
    @pending_jobs = jobs.pending
    @queued_jobs = jobs.queued
    @finished_jobs = jobs.finished.order(finished_at: :desc).page(params[:page]).per(@per_page)
  end

  def create
    order = Order.find(params[:order])
    state = order.open? ? 'queued' : 'ready'
    count = 0
    PrinterJob.transaction do
      %w[articles fax groups matrix].each do |document|
        next unless FoodsoftConfig["printer_print_order_#{document}"]

        job = PrinterJob.create! order: order, document: document, created_by: current_user
        job.add_update! state
        count += 1
      end
    end
    PrinterChannel.broadcast_unfinished
    redirect_to order, notice: t('.notice', count: count)
  end

  def show
    @job = PrinterJob.find(params[:id])
  end

  def requeue
    job = PrinterJob.find(params[:id])
    job = PrinterJob.create! order: job.order, document: job.document, created_by: current_user
    job.add_update! 'requeued'
    PrinterChannel.broadcast_unfinished
    redirect_to printer_jobs_path, notice: t('.notice')
  end

  def document
    job = PrinterJob.find(params[:id])
    send_order_pdf job.order, job.document
  end

  def destroy
    job = PrinterJob.find(params[:id])
    job.finish! current_user
    PrinterChannel.broadcast_unfinished
    redirect_to printer_jobs_path, notice: t('.notice')
  rescue StandardError => e
    redirect_to printer_jobs_path, t('errors.general_msg', msg: e.message)
  end
end
