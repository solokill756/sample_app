Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "help", to: "static_pages#help"
    get "contact", to: "static_pages#contact"

    get "signup", to: "users#new"
    post "signup", to: "users#create"

    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    
    resources :users, except: [:new, :create]  do 
      member do
          get :following, :followers
      end
    end
    resources :microposts, only: %i(create destroy)
    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new create edit update)
    resources :relationships, only: %i(create destroy)
  end
end
