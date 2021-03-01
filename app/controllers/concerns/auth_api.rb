# Controller concern for authentication methods
#
# Split off from main +ApplicationController+ to allow e.g.
# Doorkeeper to use it too.
module Concerns::AuthApi
  extend ActiveSupport::Concern

  protected

  def authenticate
    # authenticate does not look at scopes, we just want to know if there's a valid token
    # @see https://github.com/doorkeeper-gem/doorkeeper/blob/v5.0.1/lib/doorkeeper/models/access_token_mixin.rb#L218
    doorkeeper_render_error unless doorkeeper_token && doorkeeper_token.accessible?
    super if current_user
  end

  # @return [User] Current user, or +nil+ if no valid token.
  def current_user
    @current_user ||= User.undeleted.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def doorkeeper_authorize!(*scopes)
    super(*scopes)
    # In addition to Doorkeeper's authorization and scope check, we also verify
    # that the user has permissions for the scope (through its workgroups).
    # Unless no scopes were supplied, which means we only want to make sure there
    # is a valid user.
    #
    # If Doorkeeper's +handle_auth_errors+ is set to +:raise+, we don't get here,
    # but otherwise we need to check whether +super+ rendered an error.
    doorkeeper_authorize_roles!(*scopes) if scopes.present? && !performed?
  end

  private

  # Make sure that at least one the given OAuth scopes is valid for the current user's permissions.
  # @raise Api::Errors::PermissionsRequired
  def doorkeeper_authorize_roles!(*scopes)
    unless scopes.any? { |scope| doorkeeper_scope_permitted?(scope) }
      raise Api::Errors::PermissionRequired.new('Forbidden, no permission')
    end
  end

  # Check whether a given OAuth scope is permitted for the current user.
  # @note This does not validate whether the given scope is a valid scope.
  # @return [Boolean] Whether the given scope is valid for the current user.
  # @see https://github.com/foodcoops/foodsoft/issues/582#issuecomment-442513237
  def doorkeeper_scope_permitted?(scope)
    scope_parts = scope.split(':')
    # user sub-scopes like +config:user+ are always permitted
    if scope_parts.last == 'user'
      return true
    end

    case scope_parts.first
    when 'user'           then return true # access to the current user's own profile
    when 'config'         then return current_user.role_admin?
    when 'users'          then return current_user.role_admin?
    when 'workgroups'     then return current_user.role_admin?
    when 'suppliers'      then return current_user.role_suppliers?
    when 'group_orders'   then return current_user.role_orders?
    when 'finance'        then return current_user.role_finance?
      # please note that offline_access does not belong here, since it is not used for permission checking
    end

    case scope
    when 'orders:read'    then return true
    when 'orders:write'   then return current_user.role_orders?
    end
  end
end
