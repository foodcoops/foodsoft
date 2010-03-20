ActionController::Routing::Routes.draw do |map|

  # Use routing filter to select foodcoop config and datbase
  map.filter 'foodcoop', :file => File.join(RAILS_ROOT, "lib", "foodcoop_filter")

  # Root path
  map.root :controller => 'home', :action => 'index'

  # User specific
  map.logout '/logout', :controller => 'login', :action => 'logout'
  map.my_profile '/home/profile', :controller => 'home', :action => 'profile'
  map.my_ordergroup '/home/ordergroup', :controller => 'home', :action => 'ordergroup'

  # Wiki
  map.resources :pages, :collection => { :all => :get }, :member => {:version => :get, :revert => :get}
  map.wiki_page "/wiki/:permalink", :controller => 'pages', :action => 'show', :permalink => /[^\s]+/
  map.wiki "/wiki", :controller => 'pages', :action => 'show', :permalink => 'Home'

  # Orders, ordering
  map.resources :orders, :member => { :finish => :post, :add_comment => :post }
  map.with_options :controller => "ordering" do |ordering|
    ordering.ordering "/ordering", :action => "index"
    ordering.my_orders "/ordering/myOrders", :action => "myOrders"
  end


  # Foodcoop orga
  map.resources :invites, :only => [:new, :create]
  map.resources :tasks,
    :collection => {:user => :get}
  map.resources :messages, :only => [:index, :show, :new, :create],
    :member => { :reply => :get, :user => :get, :group => :get }
  map.namespace :foodcoop do |foodcoop|
    foodcoop.root :controller => "users", :action => "index"
    foodcoop.resources :users, :only => [:index]
    foodcoop.resources :ordergroups, :only => [:index]
    foodcoop.resources :workgroups, :only => [:index, :edit, :update],
      :member => {:memberships => :get}
  end

  # Article management
  map.resources :stock_takings,
    :collection => {:fill_new_stock_article_form => :get, :add_stock_article => :post}
  map.resources :stock_articles,
    :controller => 'stockit', :as => 'stockit',
    :collection => {:auto_complete_for_article_name => :get, :fill_new_stock_article_form => :get}

  map.resources :suppliers,
    :collection => { :shared_suppliers => :get } do |suppliers|
    suppliers.resources :deliveries,
      :member => { :drop_stock_change => :post },
      :collection => {:add_stock_article => :post}
    suppliers.resources :articles,
      :collection => { :update_selected => :post, :edit_all => :get, :update_all => :post,
                       :upload => :get, :parse_upload => :post, :create_from_upload => :post,
                       :shared => :get, :import => :get, :sync => :post }
  end
  map.resources :article_categories

  # Finance
  map.namespace :finance do |finance|
    finance.root :controller => 'balancing'
    finance.balancing "balancing/list", :controller => 'balancing', :action => 'list'
    finance.resources :invoices
    finance.resources :transactions
  end

  # Administration
  map.namespace :admin do |admin|
    admin.root :controller => "admin", :action => "index"
    admin.resources :users
    admin.resources :workgroups, :member => { :memberships => :get }
    admin.resources :ordergroups, :member => { :memberships => :get }
  end

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
