Rails.application.routes.draw do
  # devise_for :admins
  devise_for :user
  devise_scope :user do
    get '/login' => 'devise/sessions#new'
    get '/logout' => 'devise/sessions#destroy'
  end
  resources :users, :controller => "users"
  root :to => "dashboard#index"

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

  resources :live_statuses do
    collection do
      get :search
      get :results
    end
  end
end
