Foodsoft::Application.routes.draw do

  get "order_comments/new"

  get "comments/new"

  get "sessions/new"

  root :to => redirect("/#{FoodsoftConfig.scope}")

  scope '/:foodcoop' do

    # Root path
    root :to => 'home#index'

    ########### Sessions

    match '/login' => 'sessions#new', :as => 'login'
    match '/logout' => 'sessions#destroy', :as => 'logout'
    get '/login/new_password' => 'login#new_password', as: :new_password
    match '/login/accept_invitation/:token' => 'login#accept_invitation', as: :accept_invitation
    resources :sessions, :only => [:new, :create, :destroy]

    ########### User specific

    match '/home/profile' => 'home#profile', :as => 'my_profile'
    match '/home/ordergroup' => 'home#ordergroup', :as => 'my_ordergroup'
    match '/home/cancel_membership' => 'home#cancel_membership', :as => 'cancel_membership'

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

    resources :group_orders do
      get :archive, :on => :collection
    end

    resources :order_comments, :only => [:new, :create]

    ############ Foodcoop orga

    resources :invites, :only => [:new, :create]

    resources :tasks do
      collection do
        get :user
        get :archive
        get :workgroup
      end
      member do
        post :accept
        post :reject
        post :set_done
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
        get :articles_search
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
      root :to => 'base#index'

      resources :order, controller: 'balancing', path: 'balancing' do
        member do
          get :edit_note
          put :update_note

          get :confirm
          put :close
          put :close_direct
        end

        resources :order_articles
      end

      resources :group_order_articles do
        member do
          put :update_result
        end
      end

      resources :invoices

      resources :ordergroups, :only => [:index] do
        resources :financial_transactions, :as => :transactions
      end

      get 'transactions/new_collection' => 'financial_transactions#new_collection', :as => 'new_transaction_collection'
      post 'transactions/create_collection' => 'financial_transactions#create_collection', :as => 'create_transaction_collection'
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

    # TODO: This is very error prone. Better deactivate this catch all route
    match ':controller(/:action(/:id))(.:format)'

  end # End of /:foodcoop scope
end
