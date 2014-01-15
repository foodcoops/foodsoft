Rails.application.routes.draw do
  scope '/:foodcoop' do
    namespace :payments do
      scope '/adyen', :as => :adyen do
        post :notify, :controller => 'AdyenNotifications', :action => 'notify'

        resource :pin, :controller => 'AdyenPin', :only => [:new, :create] do
          get :index
          get :created
        end
      end
    end
  end
end
