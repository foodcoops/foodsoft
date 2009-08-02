class InvitesController < ApplicationController

  before_filter :authenticate_membership_or_admin, :only => [:new]
  #TODO: auhtorize also for create action.
  
  def new
    @invite = Invite.new(:user => @current_user, :group => @group)

    render :update do |page|
      page.replace_html :edit_box, :partial => "new"
      page.show :edit_box
    end
  end
  
  def create
    @invite = Invite.new(params[:invite])

    render :update do |page|
      if @invite.save
        page.replace_html :edit_box, :partial => "success"
      else
        page.replace_html :edit_box, :partial => "new"
      end
    end
  end
end
