Rails.application.routes.draw do
  scope '/:foodcoop' do
    resources :printer, only: [:show] do
      get :socket, on: :collection
    end

    resources :printer_jobs, only: [:index, :create, :show, :destroy] do
      get :document, on: :member
    end
  end
end
