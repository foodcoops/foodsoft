class InvitesController < ApplicationController
  before_action :authenticate_membership_or_admin_for_invites
  before_action -> { require_config_disabled :disable_invite }

  def new
    @invite = Invite.new(:user => @current_user, :group => @group)
  end

  def create
    authenticate_membership_or_admin params[:invite][:group_id]
    @invite = Invite.new(params[:invite])
    if @invite.save
      Mailer.invite(@invite).deliver_now

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

  protected

  def authenticate_membership_or_admin_for_invites
    authenticate_membership_or_admin((params[:invite][:group_id] rescue params[:id]))
  end
end
