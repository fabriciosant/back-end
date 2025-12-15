class TokenService
  def self.generate_access_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, secret_key, "HS256")
  end

  def self.decode_access_token(token)
    begin
      decoded = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::DecodeError
      nil
    end
  end

  def self.generate_refresh_token(user)
    refresh_token = SecureRandom.hex(64)
    user.update(refresh_token: refresh_token)
    refresh_token
  end

  def self.valid_refresh_token?(user, refresh_token)
    user.refresh_token == refresh_token
  end

  def self.refresh_access_token(user)
    generate_access_token(user)
  end

  private

  require "securerandom"

  def self.secret_key
    ENV["JWT_SECRET"] || Rails.application.credentials.jwt_secret
  end
end
