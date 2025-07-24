Rails.application.routes.draw do
  scope '/:foodcoop' do
    resources :group_order_invoices do
      member do
        patch :toggle_paid
      end
      collection do
        get :download_within_date
        patch :toggle_all_paid
        get :download_all
      end
    end
  end
end
