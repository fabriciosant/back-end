class Api::V1::AuthController < Devise::SessionsController
  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = JwtService.encode({ user_id: user.id })
      render json: { token: token, user: user }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: "Logged out successfully" }, status: :ok
  end
end
