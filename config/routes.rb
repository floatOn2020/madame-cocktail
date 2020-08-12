Rails.application.routes.draw do
  get 'ingredients/new'
  get 'ingredients/create'
  resources :cocktails  do
    resources :doses, only: [:new, :create]
  end
  resources :doses, only: [:destroy]
  root to: 'cocktails#index'
  resources :ingredients
end
