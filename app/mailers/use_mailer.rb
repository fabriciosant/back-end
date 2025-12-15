# app/mailers/user_mailer.rb
class UserMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: "devise/mailer"

  def confirmation_instructions(record, token, opts = {})
    # Personalize o email aqui se necessário
    super
  end
end
