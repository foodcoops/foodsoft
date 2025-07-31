Rails.application.routes.draw do
  scope '/:foodcoop' do
    post 'finance/group_order_invoice', to: 'group_order_invoices#create_multiple'

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

    resources :multi_orders, only: %i[create show destroy] do
      member do
        get :generate_ordergroup_invoices
        get :collective_direct_debit
      end
    end
  end
end
