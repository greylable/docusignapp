Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'dashboard/index'
  root 'dashboard#index'
  resources :newenvelopes
  # resources :voidenvelopes
  resources :voidenvelopes do
    collection do
      post :import
      post :destroy_multiple
    end
  end

end
