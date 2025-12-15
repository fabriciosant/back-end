# app/mailers/devise_mailer.rb
class DeviseMailer < ApplicationMailer
  include Devise::Controllers::UrlHelpers
  helper :application
  
  default template_path: 'devise/mailer'
  
  def confirmation_instructions(record, token, opts = {})
    @token = token
    @resource = record
    opts[:subject] = "🎉 Confirme sua conta no MeuApp"
    mail(to: record.email, subject: opts[:subject])
  end
  
  def reset_password_instructions(record, token, opts = {})
    @token = token
    @resource = record
    opts[:subject] = "🔑 Redefina sua senha do MeuApp"
    mail(to: record.email, subject: opts[:subject])
  end
  
  def unlock_instructions(record, token, opts = {})
    @token = token
    @resource = record
    opts[:subject] = "🚫 Sua conta do MeuApp foi bloqueada"
    mail(to: record.email, subject: opts[:subject])
  end
  
end