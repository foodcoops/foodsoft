class FeedbackController < ApplicationController

  def new
    render :update do |page|
      page.replace_html :ajax_box, :partial => "new"
      page.show :ajax_box
    end
  end

  def create
    unless params[:message].blank?
      Mailer.feedback(current_user, params[:message]).deliver
    end

    render :update do |page|
      page.replace_html :ajax_box, :partial => "success"
    end
  end

end
