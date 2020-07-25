class Admin::MailDeliveryStatusController < Admin::BaseController
  inherit_resources

  def index
    @maildeliverystatus = MailDeliveryStatus.order(created_at: :desc)
    @maildeliverystatus = @maildeliverystatus.where(email: params[:email]) unless params[:email].blank?
    @maildeliverystatus = @maildeliverystatus.page(params[:page]).per(@per_page)
  end

  def show
    @maildeliverystatus = MailDeliveryStatus.find(params[:id])
    filename = "maildeliverystatus_#{params[:id]}.#{MIME::Types[@maildeliverystatus.attachment_mime].first.preferred_extension}"
    send_data(@maildeliverystatus.attachment_data, :filename => filename, :type => @maildeliverystatus.attachment_mime)
  end

  def destroy_all
    @maildeliverystatus = MailDeliveryStatus.delete_all
    redirect_to admin_mail_delivery_status_index_path, notice: t('.notice')
  rescue => error
    redirect_to admin_mail_delivery_status_index_path, alert: I18n.t('errors.general_msg', msg: error.message)
  end

  def destroy
    @maildeliverystatus = MailDeliveryStatus.find(params[:id])
    @maildeliverystatus.destroy
    redirect_to admin_mail_delivery_status_index_path, notice: t('.notice')
  rescue => error
    redirect_to admin_mail_delivery_status_index_path, alert: I18n.t('errors.general_msg', msg: error.message)
  end
end
