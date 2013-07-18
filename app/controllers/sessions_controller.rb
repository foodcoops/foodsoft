class SessionsController < ApplicationController

  skip_before_filter :authenticate
  layout 'login'
  
  def new
  end

  def create
    user = User.authenticate(params[:nick], params[:password])
    if user
      session[:locale] = user.locale
      session[:user_id] = user.id
      session[:scope] = FoodsoftConfig.scope  # Save scope in session to not allow switching between foodcoops with one account
      session[:locale] = user_settings_language
      if session[:return_to].present?
        redirect_to_url = session[:return_to]
        session[:return_to] = nil
      else
        redirect_to_url = root_url
      end
      redirect_to redirect_to_url, :notice => I18n.t('sessions.logged_in')
    else
      flash.now.alert = I18n.t('sessions.login_invalid')
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url, :notice => I18n.t('sessions.logged_out')
  end
end
