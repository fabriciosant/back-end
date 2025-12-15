class ConfirmationMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  default template_path: "devise/mailer"

  def confirmation_instructions(record, token, opts = {})
    # Personalize o assunto
    opts[:subject] = "Confirme sua conta no MeuApp"

    # Use a variável @token que o Devise espera
    @token = token

    # Chame o método original do Devise
    devise_mail(record, :confirmation_instructions, opts)
  end
end
