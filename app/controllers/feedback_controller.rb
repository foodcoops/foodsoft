class FeedbackController < ApplicationController

  def new
    render :update do |page|
      page.replace_html :ajax_box, :partial => "new"
      page.show :ajax_box
    end
  end

  def create
    unless params[:message].blank?
      Mailer.deliver_feedback(current_user, params[:message])
    end

    render :update do |page|
      page.replace_html :ajax_box, :partial => "success"
    end
  end

end
