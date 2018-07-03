Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'
  
  
  resources :hotels
  resources :activities
  resources :users
    
  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
  post 'activities/random', to: 'activities#create_random'
  post 'hotels/random', to: 'hotels#create_random'
end
