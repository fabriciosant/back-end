# config/routes.rb
Rails.application.routes.draw do
  resources :products

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        registrations: "api/v1/registrations",
        sessions: "api/v1/auth",
        passwords: "api/v1/passwords",
        confirmations: "api/v1/confirmations"
      }, path: "", path_names: {
        registration: "register",
        sign_in: "login",
        sign_out: "logout",
        password: "password",
        confirmation: "confirmation"
      }

      resources :users, only: [ :index, :update, :destroy ], controller: "users"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
