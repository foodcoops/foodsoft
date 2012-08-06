# encoding: utf-8
class ApplicationController < ActionController::Base

  protect_from_forgery
  before_filter :select_foodcoop, :authenticate, :store_controller, :items_per_page, :set_redirect_to
  after_filter  :remove_controller

  helper_method :current_user

  # Returns the controller handling the current request.
  def self.current
    Thread.current[:application_controller]
  end

  # Use this method to call a rake task,,
  # e.g. to deliver mails after there are created.
  def call_rake(task, options = {})
    options[:rails_env] ||= Foodsoft.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "/usr/bin/rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
  end

  
  protected

  def current_user
    # check if there is a valid session and return the logged-in user (its object)
    if session[:user_id] and params[:foodcoop]
      # for shared-host installations. check if the cookie-subdomain fits to request.
      @current_user ||= User.find(session[:user_id]) if params[:foodcoop] == Foodsoft.env
    end
  end
    
  def deny_access
    self.return_to = request.request_uri
    redirect_to login_url, :alert => 'Access denied!'
  end

  private  

  def authenticate(role = 'any')
    # Attempt to retrieve authenticated user from controller instance or session...
    if !current_user
      # No user at all: redirect to login page.
      session[:user_id] = nil
      session['return_to'] = request.fullpath
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
    if Foodsoft.config[:multi_coop_install]
      if !params[:foodcoop].blank?
        begin
          # Set Config
          Foodsoft.env = params[:foodcoop]
          # Set database-connection
          ActiveRecord::Base.establish_connection(Foodsoft.database)
        rescue => error
          flash[:error] = error.to_s
          redirect_to root_path
        end
      else
        redirect_to root_path
      end
    else
      # Deactivate routing filter
      RoutingFilter::Foodcoop.active = false
    end
  end

  def items_per_page
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
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
end
