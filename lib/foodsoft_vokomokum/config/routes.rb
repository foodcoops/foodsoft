Rails.application.routes.draw do
  scope '/:foodcoop' do
    post '/login/vokomokum' => 'vokomokum#login'
    get '/finance/vokomokum_export_amounts' => 'vokomokum#export_amounts'
  end
end
