class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :skip_session
  before_action :authenticate

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_handler
  rescue_from ActiveRecord::RecordNotSaved, with: :not_acceptable_handler
  rescue_from ActiveRecord::RecordInvalid, with: :not_acceptable_handler
  rescue_from Api::Errors::PermissionRequired, with: :permission_required_handler

  private

  def authenticate
    doorkeeper_authorize!
    super if current_user
  end

  # @return [User] Current user, or +nil+ if no valid token.
  def current_user
    @current_user ||= User.undeleted.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  # @return [Ordergroup] Current user's ordergroup, or +nil+ if no valid token or user has no ordergroup.
  def current_ordergroup
    current_user.try(:ordergroup)
  end

  def require_ordergroup
    authenticate
    raise Api::Errors::PermissionRequired unless current_user.ordergroup.present?
  end

  def skip_session
    request.session_options[:skip] = true
  end

  def not_found_handler(e)
    # remove where-clauses from error message (not suitable for end-users)
    msg = e.message.try {|m| m.sub(/\s*\[.*?\]\s*$/, '')} || 'Not found'
    render status: 404, json: {error: 'not_found', error_description: msg}
  end

  def not_acceptable_handler(e)
    render status: 422, json: {error: 'not_acceptable', error_description: e.message || 'Data not acceptable' }
  end

  def doorkeeper_unauthorized_render_options(error:)
    {json: {error: error.name, error_description: error.description}}
  end

  def permission_required_handler(e)
    msg = e.message || 'Forbidden, user has no access'
    render status: 403, json: {error: 'forbidden', error_description: msg}
  end

  # @todo something with ApplicationHelper#show_user
  def show_user(user = current_user, **options)
    user.display
  end

end
