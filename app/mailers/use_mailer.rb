# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def reset_password_instructions(user, token, opts = {})
    @user = user
    @token = token
    @reset_url = "#{ENV['FRONTEND_URL']}/reset-password?reset_password_token=#{token}"

    mail(to: @user.email,
         subject: "Instruções para redefinir senha",
         template_path: "devise/mailer",
         template_name: "reset_password_instructions")
  end
end
