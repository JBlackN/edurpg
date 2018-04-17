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
    resources :character_attributes do
      resources :skills
    end
    get 'achievement_categories/new/:parent_id', to: 'achievement_categories#new'
    resources :achievement_categories do
      resources :achievements do
        resources :achi_rewards
      end
    end
    resources :items
    resources :titles
    resources :quests do
      resources :quest_rewards
    end
    resources :talent_trees do
      resources :talents
    end
  end

  root 'landing#index'
end
