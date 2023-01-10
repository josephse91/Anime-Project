Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    resources :notifications, only: [:index, :create, :show, :update]
    get "/notifications_count/:id", to: "notifications#new_notifications"
  end
end
