class FeedbackController < ApplicationController

  def new
  end

  def create
    if params[:message].present?
      Mailer.feedback(FoodsoftConfig.scope, current_user, params[:message]).deliver
      redirect_to root_url, :notice => "Das Feedback wurde erfolgreich verschickt. Vielen Dank!"
    else
      render :action => 'new'
    end
  end

end
