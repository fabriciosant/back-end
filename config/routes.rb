# config/routes.rb
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

      # Rota personalizada para confirmação de email
      get "confirm", to: "registrations#confirm"

      # Rota para testar envio de email
      post "resend_confirmation", to: "registrations#resend_confirmation"

      resources :users, only: [ :index, :update, :destroy ], controller: "users"
    end
  end

  # Adicione esta linha para letter_opener (se estiver usando letter_opener_web)
  # mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
end
