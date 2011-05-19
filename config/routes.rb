Foodsoft::Application.routes.draw do

  get "sessions/new"

  root :to => redirect("/#{Foodsoft.env}")

  scope '/:foodcoop', :defaults => { :foodcoop => Foodsoft.env } do

    # Root path
    root :to => 'home#index'

    ########### Sessions

    match '/login' => 'sessions#new', :as => 'login'
    match '/logout' => 'sessions#destroy', :as => 'logout'
    resources :sessions, :only => [:new, :create, :destroy]

    ########### User specific

    match '/home/profile' => 'home#profile', :as => 'my_profile'
    match '/home/ordergroup' => 'home#ordergroup', :as => 'my_ordergroup'

    ############ Wiki

    resources :pages do
      get :all, :on => :collection
      get :version, :on => :member
      get :revert, :on => :member
    end
    match '/wiki/:permalink' => 'pages#show', :as => 'wiki_page' # , :constraints => {:permalink => /[^\s]+/}
    match '/wiki' => 'pages#show', :defaults => {:permalink => 'Home'}, :as => 'wiki'

    ############ Orders, ordering

    resources :orders do
      member do
        post :finish
        post :add_comment
      end
    end

    match '/ordering/myOrders' => 'ordering#myOrders', :as => 'my_orders'
    match '/ordering' => 'ordering#index', :as => 'ordering'

    ############ Foodcoop orga

    resources :invites, :only => [:new, :create]

    resources :tasks do
      collection do
        get :user
        get :archive
        get :workgroup
      end
    end

    resources :messages, :only => [:index, :show, :new, :create]

    namespace :foodcoop do
      root :to => 'users#index'

      resources :users, :only => [:index]

      resources :ordergroups, :only => [:index]

      resources :workgroups, :only => [:index, :edit, :update]
    end

    ########### Article management

    resources :stock_takings do
      collection do
        get :fill_new_stock_article_form
        post :add_stock_article
      end
    end

    resources :stock_articles, :to => 'stockit' do
      collection do
        get :auto_complete_for_article_name
        get :fill_new_stock_article_form
      end
    end

    resources :suppliers do
      get :shared_suppliers, :on => :collection

      resources :deliveries do
        post :drop_stock_change, :on => :member
        post :add_stock_article, :on => :collection
      end

      resources :articles do
        collection do
          post :update_selected
          get :edit_all
          post :update_all
          get :upload
          post :parse_upload
          post :create_from_upload
          get :shared
          get :import
          post :sync
        end
      end
    end

    resources :article_categories

    ########### Finance

    namespace :finance do
      root :to => 'balancing#index'
      match 'balancing/list' => 'balancing#list', :as => 'balancing'

      resources :invoices

      resources :transactions do
        collection do
          get :new_collection
          post :create_collection
        end
      end
    end

    ########### Administration

    namespace :admin do
      root :to => 'base#index'

      resources :users

      resources :workgroups do
        get :memberships, :on => :member
      end

      resources :ordergroups do
        get :memberships, :on => :member
      end
    end

    ############## Feedback

    resource :feedback, :only => [:new, :create], :controller => 'feedback'
    
    ############## The rest

    resources :users, :only => [:index]

    match '/:controller(/:action(/:id))'

  end # End of /:foodcoop scope
end
