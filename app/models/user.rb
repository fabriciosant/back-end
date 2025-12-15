class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, :confirmable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  # Se quiser login imediato após cadastro (sem confirmação), descomente:
  # def skip_confirmation!
  #   self.confirmed_at = Time.now.utc
  # end

  # Ou para confirmar automaticamente em desenvolvimento:
  # after_create :skip_confirmation!, if: -> { Rails.env.development? }
end
