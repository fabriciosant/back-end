class Api::V1::UsersController < ApplicationController
  before_action :authenticate_with_token!
  skip_before_action :authenticate_with_token!, only: [ :index ]

 def index
   @users = User.all
   render json: @users
 end

  def update
    if current_user.update(user_params)
      render json: { message: "Usuário atualizado com sucesso", user: current_user }, status: :ok
    else
      render json: { error: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.destroy
      render json: { message: "Usuário excluído com sucesso" }, status: :ok
    else
      render json: { error: "Erro ao excluir usuário" }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  # Método para autenticar usando o JWT token
  def authenticate_with_token!
    token = request.headers["Authorization"]&.split(" ")&.last
    decoded = TokenService.decode_access_token(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      render json: { error: "Usuário não encontrado" }, status: :unauthorized unless @current_user
    else
      render json: { error: "Token inválido ou expirado" }, status: :unauthorized
    end
  end

  # Método para acessar o usuário autenticado
  def current_user
    @current_user
  end
end
