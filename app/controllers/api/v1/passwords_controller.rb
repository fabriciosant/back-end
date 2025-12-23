# app/controllers/api/v1/passwords_controller.rb
class Api::V1::PasswordsController < Devise::PasswordsController
  respond_to :json

  # POST /password (solicitar reset de senha)
  def create
    email = params[:email] || params.dig(:user, :email)

    user = User.find_by(email: email.downcase.strip)

    if user
      # O Devise vai gerar o token e enviar o email automaticamente
      raw_token = user.send_reset_password_instructions

      if raw_token
        # Opcional: Logar o token para debug (não retorne no JSON em produção)
        Rails.logger.info "Reset password token generated: #{raw_token}"

        render json: {
          success: true,
          message: "Instruções para redefinir senha foram enviadas para #{email}",
          notice: "Verifique sua caixa de entrada e pasta de spam"
        }, status: :ok
      else
        render json: {
          error: "Não foi possível gerar token de redefinição"
        }, status: :unprocessable_entity
      end
    else
      # Por segurança, não revelamos se o email existe ou não
      render json: {
        success: true,
        message: "Se este email estiver cadastrado, você receberá instruções em breve"
      }, status: :ok
    end
    rescue => e
      Rails.logger.error "Erro em PasswordsController#create: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

    render json: {
      error: "Erro interno do servidor",
      details: Rails.env.development? ? e.message : nil
    }, status: :internal_server_error
  end

  # PUT /password (atualizar senha com token)
  def update
    # Log inicial para debug
    Rails.logger.info "=== UPDATE PASSWORD START ==="
    Rails.logger.info "Params keys: #{params.keys}"
    Rails.logger.info "Params[:user]: #{params[:user].inspect}"
    Rails.logger.info "Params[:password]: #{params[:password].inspect}"

    # Há dois formatos possíveis para os parâmetros:
    # 1. { user: { reset_password_token: "...", password: "...", password_confirmation: "..." } }
    # 2. { reset_password_token: "...", password: "...", password_confirmation: "..." }

    # Primeiro, tenta extrair do formato 1
    if params[:user].present?
      reset_password_token = params[:user][:reset_password_token].to_s
      password = params[:user][:password].to_s
      password_confirmation = params[:user][:password_confirmation].to_s
    # Se não, tenta do formato 2
    else
      reset_password_token = params[:reset_password_token].to_s
      password = params[:password].to_s
      password_confirmation = params[:password_confirmation].to_s
    end

    Rails.logger.info "Token extraído: #{reset_password_token}"
    Rails.logger.info "Senha extraída: #{password}"
    Rails.logger.info "Confirmação extraída: #{password_confirmation}"

    # Validações básicas
    if reset_password_token.blank?
      Rails.logger.error "Token não fornecido"
      return render json: {
        error: "Token de recuperação é obrigatório"
      }, status: :unprocessable_entity
    end

    if password.blank?
      Rails.logger.error "Senha não fornecida"
      return render json: {
        error: "A senha é obrigatória"
      }, status: :unprocessable_entity
    end

    if password_confirmation.blank?
      Rails.logger.error "Confirmação de senha não fornecida"
      return render json: {
        error: "A confirmação de senha é obrigatória"
      }, status: :unprocessable_entity
    end

    # Validação de confirmação
    if password != password_confirmation
      Rails.logger.error "Senhas não coincidem: '#{password}' != '#{password_confirmation}'"
      return render json: {
        error: "As senhas não coincidem"
      }, status: :unprocessable_entity
    end

    Rails.logger.info "Buscando usuário com token..."
    user = User.with_reset_password_token(reset_password_token)

    if user.nil?
      Rails.logger.error "Usuário não encontrado com token: #{reset_password_token}"
      return render json: {
        error: "Token de recuperação inválido ou expirado"
      }, status: :unprocessable_entity
    end

    Rails.logger.info "Usuário encontrado: #{user.email} (#{user.id})"
    Rails.logger.info "Token no banco: #{user.reset_password_token}"
    Rails.logger.info "Token enviado: #{reset_password_token}"
    Rails.logger.info "Token válido até: #{user.reset_password_sent_at}"

    # Verifica se o token ainda é válido
    unless user.reset_password_period_valid?
      Rails.logger.error "Token expirado para usuário: #{user.email}"
      return render json: {
        error: "Token de recuperação expirado. Solicite um novo."
      }, status: :unprocessable_entity
    end

    Rails.logger.info "Tentando redefinir senha..."

    # IMPORTANTE: O Devise espera o token descriptografado, não o criptografado
    # No banco está: "12543a23301bb08c59a9211b14019b36f074c95f448108a0294053c566e22957"
    # No email está: "8HsperdiGeVHBySyVgkH" (token bruto)

    # Vamos usar o método correto do Devise
    user.password = password
    user.password_confirmation = password_confirmation

    # Limpa o token após uso
    user.clear_reset_password_token!

    if user.save
      Rails.logger.info "Senha redefinida com sucesso para #{user.email}"

      # Se a conta estava bloqueada por muitas tentativas, desbloqueia
      user.unlock_access! if user.access_locked?

      render json: {
        success: true,
        message: "Senha alterada com sucesso!",
        notice: "Você já pode fazer login com sua nova senha"
      }, status: :ok
    else
      Rails.logger.error "Erros ao salvar usuário: #{user.errors.full_messages.inspect}"

      render json: {
        error: user.errors.full_messages
      }, status: :unprocessable_entity
    end

  rescue => e
    Rails.logger.error "=== ERRO GERAL NO UPDATE ==="
    Rails.logger.error "Mensagem: #{e.message}"
    Rails.logger.error "Backtrace:"
    Rails.logger.error e.backtrace.first(10).join("\n")

    render json: {
      error: "Erro interno do servidor",
      details: Rails.env.development? ? e.message : nil
    }, status: :internal_server_error
  end


  # GET /password/edit?reset_password_token=... (verificar token)
  def edit
    reset_password_token = params[:reset_password_token]

    unless reset_password_token.present?
      return render json: {
        valid: false,
        error: "Token não fornecido"
      }, status: :bad_request
    end

    user = User.with_reset_password_token(reset_password_token)

    if user && user.reset_password_period_valid?
      render json: {
        valid: true,
        email: user.email,
        message: "Token válido. Agora você pode definir uma nova senha."
      }, status: :ok
    else
      render json: {
        valid: false,
        error: "Token inválido ou expirado"
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Erro em PasswordsController#edit: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    render json: {
      valid: false,
      error: "Erro ao validar token"
    }, status: :internal_server_error
  end

  private

  # Sobrescreve para evitar redirecionamento do Devise
  def respond_with(resource, _opts = {})
    # Não faz nada - nossos métodos já tratam as respostas JSON
  end
end
