class InvitesController < ApplicationController

  before_filter :authenticate_membership_or_admin, :only => [:new]
  #TODO: authorize also for create action.
  
  def new
    @invite = Invite.new(:user => @current_user, :group => @group)
  end
  
  def create
    @invite = Invite.new(params[:invite])
    if @invite.save
      Mailer.invite(@invite).deliver

      respond_to do |format|
        format.html do
          redirect_to root_path, notice: I18n.t('invites.success')
        end
        format.js { render layout: false }
      end

    else
      render action: :new
    end
  end
end
