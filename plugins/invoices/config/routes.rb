Rails.application.routes.draw do
  scope '/:foodcoop' do
    post 'finance/group_order_invoice', to: 'group_order_invoices#create_multiple'
    post 'finance/ordergroup_invoice', to: 'ordergroup_invoices#create_multiple'
    get 'multi_orders/:multi_order_id/ordergroup_invoices/download_all', to: 'ordergroup_invoices#download_all', as: 'download_all_ordergroup_invoices'
    post 'multi_orders/:multi_order_id/ordergroup_invoices/send_all', to: 'ordergroup_invoices#send_all', as: 'send_all_ordergroup_invoices'

    resources :orders do
      member do
        get :collective_direct_debit
      end
    end

    resources :group_order_invoices do
      member do
        patch :select_sepa_sequence_type
        patch :toggle_paid
        patch :toggle_sepa_downloaded
      end
      collection do
        get :download_within_date
        patch :select_all_sepa_sequence_type
        patch :toggle_all_paid
        patch :toggle_all_sepa_downloaded
        get :download_all
      end
    end

    resources :ordergroup_invoices do
      member do
        get :download_collective
        patch :select_sepa_sequence_type
        patch :toggle_paid
        patch :toggle_sepa_downloaded
      end
      collection do
        get :download_within_date
        patch :select_all_sepa_sequence_type
        patch :toggle_all_sepa_downloaded
        patch :toggle_all_paid
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
