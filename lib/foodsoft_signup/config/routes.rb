Rails.application.routes.draw do
  scope '/:foodcoop' do
    get  '/login/signup' => 'signup#signup', as: 'signup'
    post '/login/signup' => 'signup#signup', as: nil
  end
end
