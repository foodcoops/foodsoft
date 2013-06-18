# encoding: utf-8
class ApplicationController < ActionController::Base

  protect_from_forgery
  before_filter :select_language, :select_foodcoop, :authenticate, :store_controller, :items_per_page, :set_redirect_to
  after_filter  :remove_controller

  # Returns the controller handling the current request.
  def self.current
    Thread.current[:application_controller]
  end
  
  protected

  def current_user
    # check if there is a valid session and return the logged-in user (its object)
    if session[:user_id] and params[:foodcoop]
      # for shared-host installations. check if the cookie-subdomain fits to request.
      @current_user ||= User.find_by_id(session[:user_id]) if session[:scope] == FoodsoftConfig.scope
    end
  end
  helper_method :current_user

  def deny_access
    session[:return_to] = request.original_url
    redirect_to login_url, :alert => 'Access denied!'
  end

  private  

  def login(user)
    session[:user_id] = user.id
    session[:scope] = FoodsoftConfig.scope  # Save scope in session to not allow switching between foodcoops with one account
  end

  def logout
    session[:user_id] = nil
  end

  def authenticate(role = 'any')
    # Attempt to retrieve authenticated user from controller instance or session...
    if !current_user
      # No user at all: redirect to login page.
      logout
      session[:return_to] = request.original_url
      redirect_to login_url, :alert => 'Authentication required!'
    else
      # We have an authenticated user, now check role...
      # Roles gets the user through his memberships.
      hasRole = case role
      when "admin"  then current_user.role_admin?
      when "finance"   then  current_user.role_finance?
      when "article_meta" then current_user.role_article_meta?
      when "suppliers"  then current_user.role_suppliers?
      when "orders" then current_user.role_orders?
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

  # checks if the current_user is member of given group.
  # if fails the user will redirected to startpage
  def authenticate_membership_or_admin
    @group = Group.find(params[:id])
    unless @group.member?(@current_user) or @current_user.role_admin?
      redirect_to root_path, alert: "Diese Aktion ist nur für Mitglieder der Gruppe erlaubt!"
    end
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
    if params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end
  end

  def set_redirect_to
    session[:redirect_to] = params[:redirect_to] if params[:redirect_to]
  end

  def back_or_default_path(default = root_path)
    if session[:redirect_to].present?
      default = session[:redirect_to]
      session[:redirect_to] = nil
    end
    default
  end

  # Always stay in foodcoop url scope
  def default_url_options(options = {})
    {foodcoop: FoodsoftConfig.scope}
  end

  # returns true if @current_user's ordergroup is approved and approval is required
  def ensure_ordergroup_approved(redir_url = root_url)
    @current_user.role_admin? and return true
    unless FoodsoftConfig[:ordergroup_approval_for].nil? or
       FoodsoftConfig[:ordergroup_approval_for].member?("#{controller_name}") or
       FoodsoftConfig[:ordergroup_approval_for].member?("#{action_name}_#{controller_name}")
      return true
    end
    phrase = I18n.t("application.controller.phrases.#{action_name}_#{controller_name}",
      default: I18n.t("application.controller.phrases.#{controller_name}",
      default: I18n.t('application.controller.phrases.fallback')))
    if @current_user.ordergroup.nil?
      redirect_to redir_url, alert: I18n.t('application.controller.ordergroup_require', phrase: phrase)
    elsif !@current_user.ordergroup.approved?
      redirect_to redir_url, alert: I18n.t('application.controller.ordergroup_approval', phrase: phrase)
    end
  end

  # Used to prevent accidently switching to :en in production mode.
  def select_language
    I18n.locale = :de
  end
end
