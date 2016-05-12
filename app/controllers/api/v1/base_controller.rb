class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :skip_session
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_handler
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
    current_user.ordergroup or raise Api::Errors::PermissionRequired
  end

  def skip_session
    request.session_options[:skip] = true
  end

  def not_found_handler
    render status: 404, json: {error: 'not_found', error_description: 'Not found'}
  end

  def doorkeeper_unauthorized_render_options(error:)
    {json: {error: error.name, error_description: error.description}}
  end

  def permission_required_handler
    render status: 403, json: {error: 'forbidden', error_description: 'Forbidden, user has no access'}
  end

  # @todo something with ApplicationHelper#show_user
  def show_user(user = current_user, **options)
    user.display
  end

  # Always render with `data` root key
  # @see https://github.com/rails-api/active_model_serializers/issues/1536
  def render(*params, **options)
    super(*params, **({root: 'data'}.merge(options)))
  end

end
