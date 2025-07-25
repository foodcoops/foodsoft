# Controller concern for authentication methods
#
# Split off from main +ApplicationController+ to allow e.g.
# Doorkeeper to use it too.
module Concerns::Auth
  extend ActiveSupport::Concern

  protected

  def current_user
    # check if there is a valid session and return the logged-in user (its object)
    return unless session[:user_id] && params[:foodcoop]

    # for shared-host installations. check if the cookie-subdomain fits to request.
    @current_user ||= User.undeleted.find_by_id(session[:user_id]) if session[:scope] == FoodsoftConfig.scope
  end

  def deny_access
    session[:return_to] = request.original_url
    redirect_to root_url,
                alert: I18n.t('application.controller.error_denied',
                              sign_in: ActionController::Base.helpers.link_to(
                                t('application.controller.error_denied_sign_in'), login_path
                              ))
  end

  private

  def login(user)
    session[:user_id] = user.id
    session[:scope] = FoodsoftConfig.scope # Save scope in session to not allow switching between foodcoops with one account
    session[:locale] = user.locale
  end

  def login_and_redirect_to_return_to(user, *args)
    login user
    if session[:return_to].present?
      redirect_to_url = session[:return_to]
      session[:return_to] = nil
    else
      redirect_to_url = root_url
    end
    redirect_to redirect_to_url, *args
  end

  def logout
    session[:user_id] = nil
    session[:return_to] = nil
    expire_access_tokens
  end

  def authenticate(role = 'any')
    # Attempt to retrieve authenticated user from controller instance or session...
    if current_user
      # We have an authenticated user, now check role...
      # Roles gets the user through his memberships.

      hasRole = case role
                when 'admin'               then current_user.role_admin?
                when 'finance'             then current_user.role_finance?
                when 'article_meta'        then current_user.role_article_meta?
                when 'pickups'             then current_user.role_pickups?
                when 'suppliers'           then current_user.role_suppliers?
                when 'orders'              then current_user.role_orders?
                when 'finance_or_invoices' then current_user.role_finance? || current_user.role_invoices?
                when 'finance_or_orders'   then current_user.role_finance? || current_user.role_orders?
                when 'pickups_or_orders'   then current_user.role_pickups? || current_user.role_orders?
                when 'any'                 then true # no role required
                else false # any unknown role will always fail
                end
      if hasRole
        current_user
      else
        deny_access
      end
    else
      # No user at all: redirect to login page.
      logout
      session[:return_to] = request.original_url
      redirect_to_login alert: I18n.t('application.controller.error_authn')
    end
  end

  def authenticate_admin
    authenticate('admin')
  end

  def authenticate_finance
    authenticate('finance')
  end

  def authenticate_article_meta
    authenticate('article_meta')
  end

  def authenticate_pickups
    authenticate('pickups')
  end

  def authenticate_suppliers
    authenticate('suppliers')
  end

  def authenticate_orders
    authenticate('orders')
  end

  def authenticate_finance_or_invoices
    authenticate('finance_or_invoices')
  end

  def authenticate_finance_or_orders
    authenticate('finance_or_orders')
  end

  def authenticate_pickups_or_orders
    authenticate('pickups_or_orders')
  end

  # checks if the current_user is member of given group.
  # if fails the user will redirected to startpage
  def authenticate_membership_or_admin(group_id = params[:id])
    @group = Group.find(group_id)
    return if @group.member?(@current_user) || @current_user.role_admin?

    redirect_to root_path, alert: I18n.t('application.controller.error_members_only')
  end

  def authenticate_or_token(prefix, role = 'any')
    if params[:token].present?
      begin
        TokenVerifier.new(prefix).verify(params[:token])
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to root_path, alert: I18n.t('application.controller.error_token')
      end
    else
      authenticate(role)
    end
  end

  # Expires any access tokens for the current user (unless they have the 'offline_access' scope)
  # @see https://github.com/doorkeeper-gem/doorkeeper/issues/71#issuecomment-5471317
  def expire_access_tokens
    return unless @current_user

    Doorkeeper::AccessToken.transaction do
      token_scope = Doorkeeper::AccessToken.where(revoked_at: nil, resource_owner_id: @current_user.id)
      token_scope.each do |token|
        token.destroy! unless token.scopes.include?('offline_access')
      end
    end
  end

  # Redirect to the login page, used in authenticate, plugins can override this.
  def redirect_to_login(options = {})
    redirect_to login_url, options
  end
end
