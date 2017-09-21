Rails.application.routes.draw do

  scope '/:foodcoop' do

    get '/discourse/callback' => 'discourse#callback'
    get '/discourse/initiate' => 'discourse#initiate'

  end

end
