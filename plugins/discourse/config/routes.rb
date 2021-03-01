Rails.application.routes.draw do
  scope '/:foodcoop' do
    get '/discourse/callback' => 'discourse_login#callback'
    get '/discourse/initiate' => 'discourse_login#initiate'
    get '/discourse/sso' => 'discourse_sso#sso'
  end
end
