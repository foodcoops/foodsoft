ActionController::Routing::Routes.draw do |map|
  
  map.my_profile '/home/profile', :controller => 'home', :action => 'profile'
  map.my_ordergroup '/home/ordergroup', :controller => 'home', :action => 'ordergroup'
  map.my_tasks '/home/tasks', :controller => 'tasks', :action => 'myTasks'

  map.resources :orders, :member => { :finish => :post, :add_comment => :post }

  map.resources :messages, :only => [:index, :show, :new, :create],
    :member => { :reply => :get, :user => :get, :group => :get }

  map.namespace :admin do |admin|
    admin.resources :users
    admin.resources :workgroups, :member => { :memberships => :get }
    admin.resources :ordergroups, :member => { :memberships => :get }
  end

  map.namespace :finance do |finance|
    finance.root :controller => 'balancing'
    finance.resources :invoices
  end

  map.resources :stock_articles, :controller => 'stockit', :as => 'stockit'
  
  map.resources :suppliers, :collection => { :shared_suppliers => :get } do |suppliers|
    suppliers.resources :deliveries, :member => { :drop_stock_change => :post },
      :collection => {:add_stock_article => :post}
    suppliers.resources :articles,
      :collection => { :update_selected => :post, :edit_all => :get, :update_all => :post,
                       :upload => :get, :parse_upload => :post, :create_from_upload => :post,
                       :shared => :get, :import => :get, :sync => :post }
  end
  map.resources :article_categories

  map.root :controller => 'home', :action => 'index'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
