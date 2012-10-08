class InvitesController < ApplicationController

  before_filter :authenticate_membership_or_admin, :only => [:new]
  #TODO: auhtorize also for create action.
  
  def new
    @invite = Invite.new(:user => @current_user, :group => @group)
  end
  
  def create
    @invite = Invite.new(params[:invite])
    if @invite.save
      Mailer.delay.invite(FoodsoftConfig.scope, @invite.id)
      redirect_to back_or_default_path, notice: "Benutzerin wurde erfolgreich eingeladen."
    else
      logger.debug "[debug] errors: #{@invite.errors.messages}"
      render action: :new
    end
  end
end
