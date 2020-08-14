Rails.application.routes.draw do
  get 'pages/home'
  resources :cocktails  do
    resources :doses, only: [:new, :create]
  end
  resources :doses, only: [:destroy]
  root to: 'cocktails#index'
  resources :ingredients
end
