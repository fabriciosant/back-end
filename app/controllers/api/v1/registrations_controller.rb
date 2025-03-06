class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    user = User.new(user_params)
    if user.save
      access_token = TokenService.generate_access_token(user)
      refresh_token = TokenService.generate_refresh_token(user)

      render json: {
        message: "Usuário criado com sucesso",
        user: user,
        access_token: access_token,
        refresh_token: refresh_token
      }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    user = current_user
    if user.update(user_params)
      render json: {
        message: "Usuário atualizado com sucesso",
        user: user
      }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = current_user
    if user.destroy
      render json: { message: "Usuário excluído com sucesso" }, status: :ok
    else
      render json: { error: "Erro ao excluir usuário" }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
