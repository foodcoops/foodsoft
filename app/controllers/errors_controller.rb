class ErrorsController < ApplicationController
  include Gaffe::Errors

  skip_before_filter :authenticate

  layout :current_layout

  def show
    render "errors/#{@rescue_response}", status: @status_code
  end

  private

  def current_layout
    # Need foodcoop for `current_user`, even though it may not be retrieved from the url.
    params[:foodcoop] ||= session[:scope]
    current_user ? 'application' : 'login'
  end

  def login_layout?
    current_user.nil?
  end
  helper_method :login_layout?
end
