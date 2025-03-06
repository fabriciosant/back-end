module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header.split(" ").last if header.present?

    decoded = JwtService.decode(token)
    if decoded && decoded[:user_id]
      @current_user = User.find_by(id: decoded[:user_id])
    end

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
