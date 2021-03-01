class FeedbackController < ApplicationController
  def new
  end

  def create
    if params[:message].present?
      Mailer.feedback(current_user, params[:message]).deliver_now
      redirect_to root_url, notice: t('feedback.create.notice')
    else
      render :action => 'new'
    end
  end
end
