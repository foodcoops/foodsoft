Rails.application.routes.draw do
  scope '/:foodcoop' do
    namespace :payments do
      resource :mollie, :controller => 'MollieIdeal', :only => [:new, :create] do
        get :check
        get :result
      end
    end
  end
end
