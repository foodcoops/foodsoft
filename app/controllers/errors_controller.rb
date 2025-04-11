class ErrorsController < ApplicationController
  include Gaffe::Errors

  skip_before_action :authenticate

  layout :current_layout

  def show
    render "errors/#{@rescue_response}", formats: :html, status: @status_code
  end

  private

  def current_layout
    current_user ? 'application' : 'login'
  end

  def login_layout?
    current_user.nil?
  end
  helper_method :login_layout?
end
