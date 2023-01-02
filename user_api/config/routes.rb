Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "users#index"

  namespace :api do

    resources :users do
      get '/reviews', to: 'reviews#user_index'
      get '/rooms', to: 'users#user_rooms'
    end
    resources :reviews do
      patch '/rooms', to: 'reviews#add_review_to_rooms'
    end
    resources :review_comments
    resources :rooms do
      patch '/add_user_reviews/:user_id', to: 'rooms#add_user_reviews_to_room'
      get '/forums', to: 'forums#room_forum_index'
    end
    resources :forums
    resources :forum_comments
    resources :sessions, only: [:create,:destroy]
  end
  
end
