Rails.application.routes.draw do
  scope '/:foodcoop' do
    resources :documents do
      get :move
    end
  end
end
