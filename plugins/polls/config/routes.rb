Rails.application.routes.draw do

  scope '/:foodcoop' do

    resources :polls do
      member do
        get :vote
        post :vote
      end
    end

  end

end
