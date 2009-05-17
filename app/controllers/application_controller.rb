class ApplicationController < ActionController::Base

  # If you wanna run multiple foodcoops on one installation uncomment next line.
  #before_filter :select_foodcoop
  before_filter :authenticate, :store_controller
  after_filter  :remove_controller
  
  # sends a mail, when an error occurs
  # see plugins/exception_notification
  include ExceptionNotifiable

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
      begin
        # check if there is a valid session and return the logged-in user (its object)
        if session['user_and_subdomain']
          id, subdomain = session['user_and_subdomain'].split
          # for shared-host installations. check if the cookie-subdomain fits to request.
          return User.current_user = User.find(id) if request.subdomains.first == subdomain
        end
      rescue
        reset_session
        flash[:error]= _("An error has occurred. Please login again.")
        redirect_to :controller => 'login'
      end
    end

    def current_user=(user)
      session['user_and_subdomain'] = [user.id, request.subdomains.first].join(" ")
    end
    
    def return_to
      session['return_to']
    end

    def return_to=(uri)
      session['return_to'] = uri
    end
    
    def deny_access
      self.return_to = request.request_uri
      redirect_to :controller => '/login', :action => 'denied'
      return false
    end

  private  

    def authenticate(role = 'any')
      # Attempt to retrieve authenticated user from controller instance or session...
      if !(user = current_user)
        # No user at all: redirect to login page.
        self.return_to = request.request_uri
        redirect_to :controller => '/login'
        return false
      else
        # We have an authenticated user, now check role...
        # Roles gets the user through his memberships.
        hasRole = case role
           when "admin"  then user.role_admin?
           when "finance"   then  user.role_finance?
           when "article_meta" then user.role_article_meta?
           when "suppliers"  then user.role_suppliers?
           when "orders" then user.role_orders?
           when "any" then true        # no role required
           else false                  # any unknown role will always fail
        end        
        if hasRole
          @current_user = user
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
        flash[:error] = ERROR_NO_GROUP_MEMBER
        if request.xml_http_request?
          render(:update) {|page| page.redirect_to root_path }
        else
          redirect_to root_path
        end
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
      # Get subdomain
      subdomain = request.subdomains.first
      # Set Config
      Foodsoft.env = subdomain
      # Set database-connection
      ActiveRecord::Base.establish_connection(Foodsoft.database(subdomain))
    end
end
