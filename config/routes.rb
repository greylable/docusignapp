Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'dashboard/index'
  root 'dashboard#index'

  resources :masterlists do
    collection do
      post :select_multiple
      get :search
      get :results
      post :import
      get :export
      post :select_multiple
      get :refresh
    end
  end

  resources :newenvelopes do
    collection do
      post :import
      post :select_multiple
    end
  end

  resources :ip_newenvelopes do
    collection do
      post :import
      post :select_multiple
    end
  end

  resources :voidenvelopes do
    collection do
      post :import
      post :select_multiple
    end
  end

  resources :resendenvs do
    collection do
      post :import
      post :select_multiple
    end
  end

end
