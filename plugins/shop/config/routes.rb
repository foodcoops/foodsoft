Rails.application.routes.draw do
  scope '/:foodcoop' do
    get '/shop', to: 'foodsoft_shop#index', as: 'foodsoft_shop'
  end
end
