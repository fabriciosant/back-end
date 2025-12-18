# app/mailers/devise_mailer.rb
class DeviseMailer < ApplicationMailer
  include Devise::Controllers::UrlHelpers

  default template_path: "devise/mailer"

  def confirmation_instructions(record, token, opts = {})
    @token = token
    @resource = record
    @email = record.email

    frontend_url = Rails.application.config.host_url || "http://localhost:3000"
    @confirmation_url = "#{frontend_url}/confirmation?confirmation_token=#{token}"

    @action_url = @confirmation_url

    opts[:subject] = "Confirme sua conta"
    mail(to: record.email, subject: opts[:subject])
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    @resource = record

    frontend_url = Rails.application.config.host_url || "http://localhost:3000"
    @reset_password_url = "#{frontend_url}/reset-password?reset_password_token=#{token}"
    @action_url = @reset_password_url

    opts[:subject] = "Redefina sua senha"
    mail(to: record.email, subject: opts[:subject])
  end

  def unlock_instructions(record, token, opts = {})
    @token = token
    @resource = record
    opts[:subject] = "Sua conta do MeuApp foi bloqueada"
    mail(to: record.email, subject: opts[:subject])
  end
end
