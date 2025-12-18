class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(user_params)

    # Verifica se já existe usuário com este email
    existing_user = User.find_by(email: user_params[:email])

    if existing_user
      if existing_user.confirmed?
        return render json: {
          error: [ "Email já está em uso" ]
        }, status: :unprocessable_entity
      else
        existing_user.send_confirmation_instructions
        return render json: {
          message: "Email já cadastrado. Enviamos um novo email de confirmação.",
          requires_confirmation: true
        }, status: :ok
      end
    end

    # Salva o usuário
    resource.save

    if resource.persisted?
      begin
        resource.send_confirmation_instructions

        resource.reload

        if resource.confirmation_sent_at.present?
          email_status = "Email enviado com sucesso"
        else
          email_status = "Email NÃO enviado"
        end
      rescue => e
        email_status = "Erro: #{e.message}"
      end

      # Verifica se o usuário já está confirmado
      if resource.confirmed?
        # Gera tokens JWT
        access_token = TokenService.generate_access_token(resource)
        refresh_token = TokenService.generate_refresh_token(resource)

        render json: {
          message: "Usuário criado e confirmado com sucesso",
          user: resource,
          access_token: access_token,
          refresh_token: refresh_token
        }, status: :created
      else
        # Usuário criado mas precisa confirmar email
        render json: {
          message: "Usuário criado. Verifique seu email para confirmar sua conta.",
          debug: email_status,
          user: resource.as_json(except: [ :encrypted_password, :confirmation_token ]),
          requires_confirmation: true,
          confirmation_sent_at: resource.confirmation_sent_at
        }, status: :created
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      render json: {
        error: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # Método para confirmar email via API
  def confirm
    user = User.find_by(confirmation_token: params[:confirmation_token])

    if user
      user.confirm
      render json: {
        message: "Email confirmado com sucesso!"
      }, status: :ok
    else
      render json: {
        error: "Token de confirmação inválido"
      }, status: :unprocessable_entity
    end
  end

  def resend_confirmation
    email = params[:email] || params.dig(:user, :email)
    user = User.find_by(email: email)

    if user
      if user.confirmed?
        render json: {
          error: "Email já confirmado"
        }, status: :unprocessable_entity
      else
        user.send_confirmation_instructions
        render json: {
          message: "Email de confirmação reenviado para #{user.email}",
          confirmation_sent_at: user.confirmation_sent_at
        }, status: :ok
      end
    else
      render json: {
        error: "Usuário não encontrado"
      }, status: :not_found
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

  def sign_up_params
    user_params
  end
end
