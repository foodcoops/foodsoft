# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'order_comments/new'

  get 'comments/new'

  get 'sessions/new'

  root to: 'sessions#redirect_to_foodcoop', as: nil

  scope '/:foodcoop' do
    use_doorkeeper

    # Root path
    root to: 'home#index'

    ########### Sessions

    get   '/login' => 'sessions#new', as: 'login'
    get   '/logout' => 'sessions#destroy', as: 'logout'
    get   '/login/forgot_password' => 'login#forgot_password', as: :forgot_password
    post  '/login/reset_password' => 'login#reset_password', as: :reset_password
    get   '/login/new_password' => 'login#new_password', as: :new_password
    patch '/login/update_password' => 'login#update_password', as: :update_password
    match '/login/accept_invitation/:token' => 'login#accept_invitation', as: :accept_invitation, via: %i[get post]
    resources :sessions, only: %i[new create destroy]

    get '/foodcoop.css' => 'styles#foodcoop', as: 'foodcoop_css'

    ########### User specific

    get   '/home/profile', as: 'my_profile'
    get   '/home/reference_calculator'
    patch '/home/update_profile', as: 'update_profile'
    get   '/home/ordergroup' => 'home#ordergroup', as: 'my_ordergroup'
    post  '/home/cancel_membership' => 'home#cancel_membership', as: 'cancel_membership'

    ############ Orders, ordering

    resources :orders do
      member do
        post :finish
        post :add_comment
        post :send_result_to_supplier

        get :receive
        post :receive

        get :receive_on_order_article_create
        get :receive_on_order_article_update
      end

      resources :order_articles
    end

    resources :pickups, only: [:index] do
      post :document, on: :collection
    end

    resources :group_orders do
      get :archive, on: :collection
    end

    resources :group_order_articles

    resources :order_comments, only: %i[new create]

    ############ Foodcoop orga

    resources :invites, only: %i[new create]

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

    namespace :foodcoop do
      root to: 'users#index'

      resources :users, only: [:index]

      resources :ordergroups, only: [:index]

      resources :workgroups, only: %i[index edit update]
    end

    ########### Article management

    resources :stock_takings do
      collection do
        get :new_on_stock_article_create
      end
    end

    resources :stock_articles, controller: 'stockit' do
      get :copy
      collection do
        get :derive

        get :index_on_stock_article_create
        get :index_on_stock_article_update

        get :show_on_stock_article_update
      end
    end

    resources :article_units do
      collection do
        get :search
      end
    end

    resources :suppliers do
      get :remote_articles
      resource :share, only: %i[create destroy], controller: :supplier_shares

      resources :deliveries do
        collection do
          post :add_stock_change

          get :form_on_stock_article_create
          get :form_on_stock_article_update
        end
      end

      resources :articles do
        get :copy
        collection do
          post :update_selected
          get :edit_all
          get :prepare_units_migration
          get :migrate_units
          post :complete_units_migration
          post :update_all
          get :upload
          post :parse_upload
          post :create_from_upload
          post :sync
          post :update_synchronized
        end
      end
    end

    resources :article_categories

    ########### Finance

    namespace :finance do
      root to: 'base#index'

      resources :order, controller: 'balancing', path: 'balancing' do
        member do
          get :update_summary
          get :edit_note
          put :update_note
          get :edit_transport
          put :update_transport

          get :confirm
          post :close
          patch :close_direct

          get :new_on_order_article_create
          get :new_on_order_article_update
        end

        post :close_all_direct_with_invoice, on: :collection
      end

      resources :invoices do
        get :form_on_supplier_id_change, on: :collection
        get :unpaid, on: :collection
        delete 'delete_attachment/:attachment_id', to: 'invoices#delete_attachment', as: 'delete_attachment', on: :member
      end

      resources :links, controller: 'financial_links', only: %i[create show] do
        collection do
          get :incomplete
        end
        member do
          get :index_bank_transaction
          put 'bank_transactions/:bank_transaction', action: 'add_bank_transaction', as: 'add_bank_transaction'
          delete 'bank_transactions/:bank_transaction', action: 'remove_bank_transaction', as: 'remove_bank_transaction'

          get :index_financial_transaction
          put 'financial_transactions/:financial_transaction', action: 'add_financial_transaction',
                                                               as: 'add_financial_transaction'
          delete 'financial_transactions/:financial_transaction', action: 'remove_financial_transaction',
                                                                  as: 'remove_financial_transaction'

          get :index_invoice
          put 'invoices/:invoice', action: 'add_invoice', as: 'add_invoice'
          delete 'invoices/:invoice', action: 'remove_invoice', as: 'remove_invoice'

          get :new_financial_transaction
          post :create_financial_transaction
        end
      end

      resources :ordergroups, only: [:index] do
        resources :financial_transactions, as: :transactions
      end
      resources :financial_transactions, as: :foodcoop_financial_transactions, path: 'foodcoop/financial_transactions',
                                         only: %i[index new create]
      get :transactions, controller: :financial_transactions, action: :index_collection
      delete 'transactions/:id', controller: :financial_transactions, action: :destroy, as: :transaction

      get 'transactions/new_collection' => 'financial_transactions#new_collection', as: 'new_transaction_collection'
      post 'transactions/create_collection' => 'financial_transactions#create_collection',
           as: 'create_transaction_collection'

      resources :bank_accounts, only: [:index] do
        member do
          get :assign_unlinked_transactions
          get :import
          post :import
        end

        resources :bank_transactions, as: :transactions
      end

      resources :bank_transactions, only: %i[index show]
    end

    ########### Administration

    namespace :admin do
      root to: 'base#index'

      resources :finances, only: [:index] do
        get :update_bank_accounts, on: :collection
        get :update_bank_gateways, on: :collection
        get :update_transaction_types, on: :collection
        get :update_supplier_categories, on: :collection
      end

      resources :bank_accounts
      resources :bank_gateways
      resources :financial_transaction_classes
      resources :financial_transaction_types
      resources :supplier_categories

      resources :users do
        post :restore, on: :member
        post :sudo, on: :member
      end

      resources :workgroups do
        get :memberships, on: :member
      end

      resources :ordergroups do
        get :memberships, on: :member
      end

      resources :mail_delivery_status, only: %i[index show destroy] do
        delete :index, on: :collection, action: :destroy_all
      end

      resource :config, only: %i[show update] do
        get :list
      end
    end

    ############## API

    namespace :api do
      namespace :v1 do
        resource :config, only: [:show]
        resource :navigation, only: [:show]

        namespace :user do
          root to: 'users#show'
          get :financial_overview, to: 'ordergroup#financial_overview'
          resources :financial_transactions, only: %i[index show create]
          resources :group_order_articles
        end

        resources :financial_transaction_classes, only: %i[index show]
        resources :financial_transaction_types, only: %i[index show]
        resources :financial_transactions, only: %i[index show]
        resources :orders, only: %i[index show]
        resources :order_articles, only: %i[index show]
        resources :group_order_articles
        resources :article_categories, only: %i[index show]

        resources :shared_suppliers, param: :uuid, only: [] do
          resources :articles, only: [:index]
        end
      end
    end

    ############## The rest

    resources :users, only: [:index]
  end # End of /:foodcoop scope
end
