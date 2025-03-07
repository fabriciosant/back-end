Rails.application.routes.draw do
  resources :products

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        registrations: "api/v1/registrations",
        sessions: "api/v1/auth"
      }, path: "", path_names: {
        registration: "register",
        sign_in: "login",
        sign_out: "logout"
      }
      resource :user, only: [:update, :destroy], controller: "users"
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end

