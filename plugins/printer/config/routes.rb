Rails.application.routes.draw do
  scope '/:foodcoop' do
    namespace :api do
      namespace :v1 do
        resources :printer, only: [:show]
      end
    end

    resources :printer_jobs, only: [:index, :create, :show, :destroy] do
      get :document, on: :member
    end
  end
end
