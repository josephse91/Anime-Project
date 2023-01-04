Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do

    resources :show_ratings
    get '/rooms/:room_id/show_ratings', to: 'show_ratings#room_show_index'
    
  end
end
