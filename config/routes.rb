Rails.application.routes.draw do
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :restaurant

  resources :user

  resources :reservation

  resources :sessions, only: [:new, :create, :destroy]
end
