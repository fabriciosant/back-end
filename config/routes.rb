Rails.application.routes.draw do
  resources :products
  namespace :api do
    namespace :v1 do
      devise_for :users, path: "auth", controllers: {
        registrations: "api/v1/registrations",
        sessions: "api/v1/auth"
      }
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
