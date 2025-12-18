Devise.setup do |config|
  # Configurações de email - ajuste para seu domínio
  config.mailer_sender = ENV["GMAIL_USERNAME"]
  config.mailer = 'DeviseMailer'

  # Se você quiser usar um mailer personalizado
  # config.mailer = "UserMailer"

  require "devise/orm/active_record"

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [ :http_auth ]
  config.stretches = Rails.env.test? ? 1 : 12
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # Configurações de confirmação de email
  config.confirm_within = 3.days
  config.confirmation_keys = [ :email ]
  config.reconfirmable = true

  # Se você quiser permitir login sem confirmação (não recomendado para APIs)
  config.allow_unconfirmed_access_for = 0.days

  # Configurações JWT (se estiver usando)
  config.jwt do |jwt|
    jwt.secret = ENV["DEVISE_JWT_SECRET_KEY"] || Rails.application.credentials.devise_jwt_secret_key
    jwt.expiration_time = 24.hours.to_i
  end
end
