class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :destroy_session
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def authenticate
    doorkeeper_authorize!
    super if current_user
  end

  def current_user
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def not_found
    render status: 404, json: {error: 'Not found'}
  end
end
