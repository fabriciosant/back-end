class Api::V1::AuthController < Devise::SessionsController
  def create
    # Aceita ambos os formatos: com ou sem nesting 'user'
    email = params.dig(:user, :email) || params[:email]
    password = params.dig(:user, :password) || params[:password]

    user = User.find_by(email: email)

    if user&.valid_password?(password)
      access_token = TokenService.generate_access_token(user)
      refresh_token = TokenService.generate_refresh_token(user)

      render json: {
        message: "Bem vindo de volta!",
        access_token: access_token,
        refresh_token: refresh_token,
        user: user.as_json(except: [ :encrypted_password, :reset_password_token ])
      }, status: :ok
    else
      render json: { error: "Email ou senha Inválido!" }, status: :unauthorized
    end
  end

 def destroy
    # Versão mais simples - apenas responde com sucesso
    # Se estiver usando JWT stateless, não precisa fazer nada no servidor
    render json: {
      message: "Logout realizado com sucesso! Até breve, volte sempre!"
    }, status: :ok
  end

  private

  # Sobrescreva para evitar o comportamento padrão do Devise
  def respond_to_on_destroy
    # Não faz nada - nosso método destroy já trata a resposta
  end
end
