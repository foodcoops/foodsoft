class SessionsController < ApplicationController

  skip_before_filter :authenticate
  layout 'login'
  
  def new
  end

  def create
    user = User.authenticate(params[:nick], params[:password])
    if user
      session[:user_id] = user.id
      session[:scope] = FoodsoftConfig.scope  # Save scope in session to not allow switching between foodcoops with one account
      session[:locale] = user.locale

      if session[:return_to].present?
        redirect_to_url = session[:return_to]
        session[:return_to] = nil
      else
        redirect_to_url = root_url
      end
      redirect_to redirect_to_url, :notice => I18n.t('sessions.logged_in')
    else
      flash.now.alert = I18n.t(FoodsoftConfig[:use_nick] ? 'sessions.login_invalid_nick' : 'sessions.login_invalid_email')
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    session[:return_to] = nil
    redirect_to login_url, :notice => I18n.t('sessions.logged_out')
  end

  # redirect to root, going to default foodcoop when none given
  # this may not be so much session-related, but it must be somewhere
  def redirect_to_foodcoop
    redirect_to root_path
  end

end
