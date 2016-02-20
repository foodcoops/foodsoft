Rails.application.routes.draw do

  scope '/:foodcoop' do

    resources :documents

  end

end
