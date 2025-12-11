class Api::BaseController < ApplicationController
  include Concerns::AuthApi

  protect_from_forgery with: :null_session

  before_action :skip_session
  before_action :authenticate

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_handler
  rescue_from ActiveRecord::RecordNotSaved, with: :not_acceptable_handler
  rescue_from ActiveRecord::RecordInvalid, with: :not_acceptable_handler
  rescue_from Api::Errors::PermissionRequired, with: :permission_required_handler

  private

  # @return [Ordergroup] Current user's ordergroup, or +nil+ if no valid token or user has no ordergroup.
  def current_ordergroup
    current_user.try(:ordergroup)
  end

  def require_ordergroup
    authenticate
    return if current_ordergroup.present?

    raise Api::Errors::PermissionRequired, 'Forbidden, must be in an ordergroup'
  end

  def require_minimum_balance
    minimum_balance = FoodsoftConfig[:minimum_balance] or return
    return unless current_ordergroup.account_balance < minimum_balance

    raise Api::Errors::PermissionRequired, t('application.controller.error_minimum_balance', min: minimum_balance)
  end

  def require_enough_apples
    return unless current_ordergroup.not_enough_apples?

    s = t('group_orders.messages.not_enough_apples', apples: current_ordergroup.apples,
                                                     stop_ordering_under: FoodsoftConfig[:stop_ordering_under])
    raise Api::Errors::PermissionRequired, s
  end

  def require_config_enabled(config)
    return if FoodsoftConfig[config]

    raise Api::Errors::PermissionRequired, t('application.controller.error_not_enabled', config: config)
  end

  def skip_session
    request.session_options[:skip] = true
  end

  def not_found_handler(e)
    # remove where-clauses from error message (not suitable for end-users)
    msg = e.message.try { |m| m.sub(/\s*\[.*?\]\s*$/, '') } || 'Not found'
    render status: :not_found, json: { error: 'not_found', error_description: msg }
  end

  def not_acceptable_handler(e)
    msg = e.message || 'Data not acceptable'
    render status: :unprocessable_entity, json: { error: 'not_acceptable', error_description: msg }
  end

  def doorkeeper_unauthorized_render_options(error:)
    { json: { error: error.name, error_description: error.description } }
  end

  def doorkeeper_forbidden_render_options(error:)
    { json: { error: error.name, error_description: error.description } }
  end

  def permission_required_handler(e)
    msg = e.message || 'Forbidden, user has no access'
    render status: :forbidden, json: { error: 'forbidden', error_description: msg }
  end

  # @todo something with ApplicationHelper#show_user
  def show_user(user = current_user, **_options)
    user.display
  end
end
