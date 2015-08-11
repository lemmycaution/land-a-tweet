Rails.application.routes.draw do
  resources :donations, only: [:update]

  scope 'admin', module: 'admin' do
    resources :donors
    resources :tweets do
      get :broadcast, to: 'tweets#count_broadcast', on: :member
      post :broadcast, to: 'tweets#broadcast', on: :member
    end
  end
  devise_for :admin_users, path: 'admin'
  get 'admin', to: 'admin/tweets#index', as: 'admin_root'

  root 'pages#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/auth/:provider', to: 'sessions#destroy'
  get "/auth/failure", to: "sessions#failure"


end
