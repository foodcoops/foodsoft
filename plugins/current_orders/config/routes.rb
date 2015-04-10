Rails.application.routes.draw do
  scope '/:foodcoop' do
    namespace :current_orders do
      resources :ordergroups, :only => [:index, :show] do
        collection do
          get :show_on_group_order_article_create
          get :show_on_group_order_article_update
        end
      end

      resources :articles, :only => [:index, :show] do
        collection do
          get :show_on_group_order_article_create
        end
      end

      resource :orders, :only => [:show] do
        collection do
          get :my
          get :receive
        end
      end

      resources :group_orders, :only => [:index]
    end
  end
end
