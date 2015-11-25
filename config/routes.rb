Rails.application.routes.draw do
  resources :donations, only: [:update]

  scope 'admin', module: 'admin' do
    resources :donors
    resources :pages
    resources :tweets do
      get :broadcast, to: 'tweets#count_broadcast', on: :member
      post :broadcast, to: 'tweets#broadcast', on: :member
    end
    get 'panic', to: 'panic#index'
    delete 'panic/jobs/stop', to: 'panic#stop_dj'
    post 'panic/jobs/start', to: 'panic#start_dj'
    delete 'panic/donors', to: 'panic#delete_all_donors'
    put 'panic/frontend/suspend', to: 'panic#suspend_frontend'
    put 'panic/frontend/activate', to: 'panic#activate_frontend'
  end
  devise_for :admin_users, path: 'admin'
  get 'admin', to: 'admin/tweets#index', as: 'admin_root'

  get 'pages/:slug', to: 'pages#show', as: 'public_page' #FIX: fix this cause admin gets page route
  get 'jsapi', to: 'pages#jsapi', format: 'js'
  root 'pages#show', slug: 'index'

  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/auth/:provider', to: 'sessions#destroy'
  get "/auth/failure", to: "sessions#failure"
  get "/auth/check", to: "sessions#check"


end
