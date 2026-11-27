Rails.application.routes.draw do
  scope '/:foodcoop' do
    namespace :pickup do
      # The listing a member's app needs. Kept under a plural resource name
      # even though #index is the only action, so that a later detail route
      # does not change the path.
      resources :group_orders, only: [:index]
    end
  end
end
