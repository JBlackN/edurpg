Rails.application.routes.draw do
  get 'landing/index'

  get 'login', to: redirect('/auth/fitcvut_oauth2'), as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/fitcvut_oauth2/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  resources :consents
  get 'sessions/index'

  get 'dashboards/index'

  namespace :admin do
    get 'dashboards/index'
  end

  root 'landing#index'
end
