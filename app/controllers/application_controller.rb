# encoding: utf-8
class ApplicationController < ActionController::Base
  include Foodsoft::ControllerExtensions::Locale
  helper_method :available_locales

  protect_from_forgery
  before_filter  :select_foodcoop, :authenticate, :set_user_last_activity, :store_controller, :items_per_page
  after_filter  :remove_controller
  around_filter :set_time_zone, :set_currency

  
  # Returns the controller handling the current request.
  def self.current
    Thread.current[:application_controller]
  end
  
  protected

  def current_user
    # check if there is a valid session and return the logged-in user (its object)
    if session[:user_id] && params[:foodcoop]
      # for shared-host installations. check if the cookie-subdomain fits to request.
      @current_user ||= User.find_by_id(session[:user_id]) if session[:scope] == FoodsoftConfig.scope
    end
  end
  helper_method :current_user

  def deny_access
    session[:return_to] = request.original_url
    redirect_to root_url, alert: I18n.t('application.controller.error_denied', sign_in: ActionController::Base.helpers.link_to(t('application.controller.error_denied_sign_in'), login_path))
  end

  private

  def login(user)
    session[:user_id] = user.id
    session[:scope] = FoodsoftConfig.scope  # Save scope in session to not allow switching between foodcoops with one account
    session[:locale] = user.locale
  end

  def logout
    session[:user_id] = nil
    session[:return_to] = nil
  end

  def authenticate(role = 'any')
    # Attempt to retrieve authenticated user from controller instance or session...
    if !current_user
      # No user at all: redirect to login page.
      logout
      session[:return_to] = request.original_url
      redirect_to_login :alert => I18n.t('application.controller.error_authn')
    else
      # We have an authenticated user, now check role...
      # Roles gets the user through his memberships.
      hasRole = case role
      when "admin"  then current_user.role_admin?
      when "finance"   then  current_user.role_finance?
      when "article_meta" then current_user.role_article_meta?
      when "suppliers"  then current_user.role_suppliers?
      when "orders" then current_user.role_orders?
      when "finance_or_orders" then (current_user.role_finance? || current_user.role_orders?)
      when "any" then true        # no role required
      else false                  # any unknown role will always fail
      end
      if hasRole
        current_user
      else
        deny_access
      end
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

  def authenticate_suppliers
    authenticate('suppliers')
  end

  def authenticate_orders
    authenticate('orders')
  end

  def authenticate_finance_or_orders
    authenticate('finance_or_orders')
  end

  # checks if the current_user is member of given group.
  # if fails the user will redirected to startpage
  def authenticate_membership_or_admin(group_id = params[:id])
    @group = Group.find(group_id)
    unless @group.member?(@current_user) || @current_user.role_admin?
      redirect_to root_path, alert: I18n.t('application.controller.error_members_only')
    end
  end

  def authenticate_or_token(prefix, role = 'any')
    if not params[:token].blank?
      begin
        TokenVerifier.new(prefix).verify(params[:token])
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to root_path, alert: I18n.t('application.controller.error_token')
      end
    else
      authenticate(role)
    end
  end

  def set_user_last_activity
    if current_user && (session[:last_activity] == nil || session[:last_activity] < 1.minutes.ago)
      current_user.update_attribute(:last_activity, Time.now)
      session[:last_activity] = Time.now
    end
  end

  # Many plugins can be turned on and off on the fly with a `use_` configuration option.
  # To disable a controller in the plugin, you can use this as a `before_action`:
  #
  #     class MypluginController < ApplicationController
  #       before_filter -> { require_plugin_enabled FoodsoftMyplugin }
  #     end
  #
  def require_plugin_enabled(plugin)
    unless plugin.enabled?
      redirect_to root_path, alert: I18n.t('application.controller.error_plugin_disabled')
    end
  end

  # Redirect to the login page, used in authenticate, plugins can override this.
  def redirect_to_login(options={})
    redirect_to login_url, options
  end

  # Stores this controller instance as a thread local varibale to be accessible from outside ActionController/ActionView.
  def store_controller
    Thread.current[:application_controller] = self
  end
    
  # Sets the thread local variable that holds a reference to the current controller to nil.
  def remove_controller
    Thread.current[:application_controller] = nil
  end

  # Get supplier in nested resources
  def find_supplier
    @supplier = Supplier.find(params[:supplier_id]) if params[:supplier_id]
  end

  # Set config and database connection for each request
  # It uses the subdomain to select the appropriate section in the config files
  # Use this method as a before filter (first filter!) in ApplicationController
  def select_foodcoop
    if FoodsoftConfig[:multi_coop_install]
      if params[:foodcoop].present?
        begin
          # Set Config and database connection
          FoodsoftConfig.select_foodcoop params[:foodcoop]
        rescue => error
          redirect_to root_url, alert: error.message
        end
      else
        redirect_to root_url
      end
    end
  end

  def items_per_page
    if params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 500
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end
  end

  # Always stay in foodcoop url scope
  def default_url_options(options = {})
    {foodcoop: FoodsoftConfig.scope}
  end

  # Set timezone according to foodcoop preference.
  # @see http://stackoverflow.com/questions/4362663/timezone-with-rails-3
  # @see http://archives.ryandaigle.com/articles/2008/1/25/what-s-new-in-edge-rails-easier-timezones
  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = FoodsoftConfig[:time_zone] if FoodsoftConfig[:time_zone]
    yield
  ensure
    Time.zone = old_time_zone
  end

  # Set currency according to foodcoop preference.
  # @see #set_time_zone
  def set_currency
    old_currency = ::I18n.t('number.currency.format.unit')
    new_currency = FoodsoftConfig[:currency_unit] || ''
    new_currency += "\u202f" if FoodsoftConfig[:currency_space]
    ::I18n.backend.store_translations(::I18n.locale, number: {currency: {format: {unit: new_currency}}})
    yield
  ensure
    ::I18n.backend.store_translations(::I18n.locale, number: {currency: {format: {unit: old_currency}}})
  end

end
