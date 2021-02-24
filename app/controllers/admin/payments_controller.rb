# encoding: utf-8
class Admin::PaymentsController < Admin::BaseController
  inherit_resources

  def index
    @payments = Payment.undeleted.order('name ASC')

    unless params[:query].blank?
      @payments = @payments.where('name LIKE ?', "%#{params[:query]}%")
    end

    @payments = @payments.page(params[:page]).per(@per_page)
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.mark_as_deleted
    redirect_to admin_payments_url, notice: t('admin.payments.destroy.notice')
  rescue => error
    redirect_to admin_payments_url, alert: t('admin.payments.destroy.error')
  end
end
