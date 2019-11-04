Rails.application.routes.draw do

  scope '/:foodcoop' do

    resources :links, only: [:show]

    namespace :admin do
      resources :links
    end

  end

end
