class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, :confirmable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null


  def send_on_create_confirmation_instructions
  end
end
