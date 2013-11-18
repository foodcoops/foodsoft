Rails.application.routes.draw do

  scope '/:foodcoop' do

    resources :pages do
      get :all, :on => :collection
      get :version, :on => :member
      get :revert, :on => :member
    end
    match '/wiki/:permalink' => 'pages#show', :as => 'wiki_page' # , :constraints => {:permalink => /[^\s]+/}
    match '/wiki' => 'pages#show', :defaults => {:permalink => 'Home'}, :as => 'wiki'

  end

end
