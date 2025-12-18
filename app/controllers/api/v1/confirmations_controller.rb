# app/controllers/api/v1/confirmations_controller.rb
module Api
  module V1
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json

      # POST /api/v1/confirmation
      def create
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        if resource.errors.empty?
          render json: {
            success: true,
            message: "Conta confirmada com sucesso!"
          }, status: :ok
        else
          render json: {
            success: false,
            error: resource.errors.full_messages.first || "Token inválido ou expirado"
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/confirmation?confirmation_token=...
      # (Opcional, se quiser suportar GET também)
      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        if resource.errors.empty?
          render json: {
            success: true,
            message: "Conta confirmada com sucesso!"
          }, status: :ok
        else
          render json: {
            success: false,
            error: resource.errors.full_messages.first || "Token inválido ou expirado"
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
