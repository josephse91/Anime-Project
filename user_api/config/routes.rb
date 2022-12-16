Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "users#index"

  namespace :api do

    resources :users do
      get '/reviews', to: 'reviews#user_index'
    end
    resources :reviews
    resources :review_comments
    resources :rooms
    resources :sessions, only: [:create,:destroy]
  end
  
end
