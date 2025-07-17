Rails.application.routes.draw do
  scope '/:foodcoop' do
    resources :group_order_invoices do
      member do
        patch :select_sepa_sequence_type
        patch :toggle_paid
        patch :toggle_sepa_downloaded
      end
      collection do
        get :download_within_date
        patch :select_all_sepa_sequence_type
        patch :toggle_all_sepa_downloaded
        patch :toggle_all_paid
        get :download_all
      end
    end
  end
end
