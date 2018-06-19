Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :hotels
  resources :activities
  resources :users
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
end
