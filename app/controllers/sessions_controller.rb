class SessionsController < ApplicationController
  skip_before_action :authenticate
  layout 'login'

  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    user = User.authenticate(params[:nick], params[:password])
    if user
      user.update_attribute(:last_login, Time.now)
      login_and_redirect_to_return_to user, :notice => I18n.t('sessions.logged_in')
    else
      flash.now.alert = I18n.t(FoodsoftConfig[:use_nick] ? 'sessions.login_invalid_nick' : 'sessions.login_invalid_email')
      render "new"
    end
  end

  def destroy
    logout
    if FoodsoftConfig[:logout_redirect_url].present?
      redirect_to FoodsoftConfig[:logout_redirect_url]
    else
      redirect_to login_url, :notice => I18n.t('sessions.logged_out')
    end
  end

  # redirect to root, going to default foodcoop when none given
  # this may not be so much session-related, but it must be somewhere
  def redirect_to_foodcoop
    redirect_to root_path
  end
end
