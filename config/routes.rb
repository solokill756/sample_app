Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "help", to: "static_pages#help"
    get "contact", to: "static_pages#contact"

    get "signup", to: "users#new"
    post "signup", to: "users#create"
    get "users/:id/edit", to: "users#edit", as: :edit_user
    patch "users/:id", to: "users#update"

    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    resources :users, only: %i(index show destroy)
    resources :microposts, only: :index
    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new create edit update)
  end
end
