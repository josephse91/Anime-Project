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
    resources :rooms do
      get '/forums', to: 'forums#room_forum_index'
    end
    resources :forums
    resources :forum_comments
    resources :sessions, only: [:create,:destroy]
  end
  
end
