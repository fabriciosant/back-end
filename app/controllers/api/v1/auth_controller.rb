class Api::V1::AuthController < Devise::SessionsController
  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      access_token = TokenService.generate_access_token(user)
      refresh_token = TokenService.generate_refresh_token(user)

      render json: { 
        message: "Bem vindo de volta!",
        access_token: access_token, 
        refresh_token: refresh_token, 
        user: user 
      }, status: :ok
    else
      render json: { error: "Email ou senha Inválido!" }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: "Até breve, volte sempre!" }, status: :ok
  end
end

