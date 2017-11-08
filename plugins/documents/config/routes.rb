Rails.application.routes.draw do

  scope '/:foodcoop' do

    resources :documents do
      get :new
      get :new_folder
    end

  end

end
