Rails.application.routes.draw do
  scope '/:foodcoop' do
    resources :messages, :only => [:index, :show, :new, :create] do
      member do
        get :thread
      end
    end

    resources :messagethreads, :only => [:index, :show]

    resources :messagegroups, only: [:index] do
      member do
        post :join
        post :leave
      end
    end

    namespace :admin do
      resources :messagegroups do
        get :memberships, on: :member
      end
    end
  end
end
