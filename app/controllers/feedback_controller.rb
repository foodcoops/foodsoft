class FeedbackController < ApplicationController

  def new
  end

  def create
    unless params[:message].blank?
      Mailer.feedback(current_user, params[:message]).deliver
      redirect_to new_feedback_url, :notice => 'The message was successfully delivered.'
    else
      render :action => 'new'
    end
  end

end
