class ApplicationController < ActionController::API
    rescue_from ActionController::UnpermittedParameters, with: :handle_unpermitted_params
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_parse_error

    private

    def handle_unpermitted_params(exception)
        render json: { error: "Parâmetros inválidos: [#{exception.params.join(', ')}]" },
            status: :unprocessable_entity
    end

    def handle_parse_error(exception)
        render json: { error: "JSON inválido: #{exception.message}" }, status: :bad_request
    end
end
