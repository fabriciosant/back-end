# app/controllers/api/v1/passwords_controller.rb
class Api::V1::PasswordsController < Devise::PasswordsController
  respond_to :json
  
  # POST /api/v1/password (solicitar reset de senha)
  def create
    email = params[:email] || params.dig(:user, :email)
    
    # Busca o usuário pelo email
    user = User.find_by(email: email)
    
    if user
      # Gera token de reset e envia email
      token = user.send_reset_password_instructions
      
      render json: {
        message: "Instruções para redefinir senha foram enviadas para #{email}",
        notice: "Verifique sua caixa de entrada e pasta de spam",
        reset_password_token: token  # Apenas para desenvolvimento/teste
      }, status: :ok
    else
      # Por segurança, não revelamos se o email existe ou não
      render json: {
        message: "Se este email estiver cadastrado, você receberá instruções em breve"
      }, status: :ok
    end
  end
  
  # PUT /api/v1/password (atualizar senha com token)
  def update
    # Pode receber o token de duas formas
    reset_password_token = params[:reset_password_token] || params.dig(:user, :reset_password_token)
    password = params[:password] || params.dig(:user, :password)
    password_confirmation = params[:password_confirmation] || params.dig(:user, :password_confirmation)
    
    user = User.with_reset_password_token(reset_password_token)
    
    if user.nil?
      return render json: {
        error: "Token de recuperação inválido ou expirado"
      }, status: :unprocessable_entity
    end
    
    # Tenta atualizar a senha
    if user.reset_password(password, password_confirmation)
      # Se a conta estava bloqueada por muitas tentativas, desbloqueia
      user.unlock_access! if user.access_locked?
      
      render json: {
        message: "Senha alterada com sucesso!",
        notice: "Você já pode fazer login com sua nova senha"
      }, status: :ok
    else
      render json: {
        error: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  # GET /api/v1/password/edit?reset_password_token=... (verificar token)
  def edit
    reset_password_token = params[:reset_password_token]
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
  end
  
  private
  
  # Sobrescreve para evitar redirecionamento do Devise
  def respond_with(resource, _opts = {})
    # Não faz nada - nossos métodos já tratam as respostas JSON
  end
end