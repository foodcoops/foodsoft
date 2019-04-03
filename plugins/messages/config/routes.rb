Rails.application.routes.draw do
  scope '/:foodcoop' do
    resources :messages, :only => [:index, :show, :new, :create] do
      member do
        get :thread
        post :toggle_private
      end
    end

    resources :message_threads, :only => [:index, :show]

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
