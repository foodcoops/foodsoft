class FoodcoopController < ApplicationController

  before_filter :authenticate_membership_or_admin

  # Invites a new user to join foodsoft in this group.
  def invite
    @invite = Invite.new
  end

  # Sends an email
  def send_invitation
    @invite = Invite.new(:user => @current_user, :group => @group, :email => params[:invite][:email])
    if @invite.save
      flash[:notice] = format('Es wurde eine Einladung an %s geschickt.', @invite.email)
      redirect_to root_path
    else
      render :action => 'invite'
    end
  end
end
