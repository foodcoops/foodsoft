Rails.application.routes.draw do
  scope '/:foodcoop' do
    resources :messages, :only => [:index, :show, :new, :create]
  end
end
