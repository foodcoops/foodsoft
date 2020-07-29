Rails.application.routes.draw do

  scope '/:foodcoop' do

    resources :links, only: [:show]

  end

end
