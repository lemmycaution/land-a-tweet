Rails.application.routes.draw do
  root 'pages#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/auth/:provider', to: 'sessions#destroy'
  get "/auth/failure", to: "sessions#failure"

  resources :identities, only: [:update]
end
