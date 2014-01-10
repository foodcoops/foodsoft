Rails.application.routes.draw do
  scope '/:foodcoop' do
    post '/login/vokomokum' => 'vokomokum#login'
  end
end
