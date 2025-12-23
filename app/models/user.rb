class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable


  def send_reset_password_instructions(opts = {})
    token = set_reset_password_token
    send_devise_notification(:reset_password_instructions, token, opts)
    token
  end
end
