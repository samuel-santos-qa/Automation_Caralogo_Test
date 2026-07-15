require 'json'
require 'time'

module AuthSession
  REQUIRED_ENV_VARS = %w[
    CARALOGO_QA_AUTH_SECRET
    CARALOGO_QA_EMAIL
    CARALOGO_QA_PASSWORD
  ].freeze
  EXPIRY_SAFETY_WINDOW_SECONDS = 10
  SAFE_ERROR_FIELDS = %w[statusCode error message].freeze

  class << self
    # Retorna headers autenticados e renova o token QA quando ele não estiver válido.
    def auth_headers
      fetch_token!

      { 'Authorization' => "Bearer #{@access_token}" }
    end

    # Obtém e mantém em memória um token QA válido sem expor credenciais ou token.
    def fetch_token!
      ensure_auth_enabled!
      return @access_token if token_valid?

      validate_required_environment!
      response = request_token
      validate_token_response!(response)
      store_token_data!(response.parsed_response)

      @access_token
    end

    private

    # Impede o uso acidental da infraestrutura autenticada sem a flag explícita.
    def ensure_auth_enabled!
      return if ENV['CARALOGO_AUTH_ENABLED'] == 'true'

      raise 'Autenticação QA desabilitada. Execute com: ' \
            'CARALOGO_AUTH_ENABLED=true bundle exec cucumber -p auth'
    end

    # Valida apenas a presença das configurações obrigatórias, sem incluir seus valores no erro.
    def validate_required_environment!
      missing_vars = REQUIRED_ENV_VARS.select { |name| ENV[name].nil? || ENV[name].strip.empty? }
      return if missing_vars.empty?

      raise "Variáveis de ambiente obrigatórias ausentes: #{missing_vars.join(', ')}"
    end

    # Solicita um token QA com credenciais mantidas exclusivamente no ambiente local.
    def request_token
      CaralogoApi.post(
        '/qa/auth/token',
        headers: {
          'accept' => 'application/json',
          'x-qa-auth-secret' => ENV['CARALOGO_QA_AUTH_SECRET'],
          'Content-Type' => 'application/json'
        },
        body: JSON.generate(
          email: ENV['CARALOGO_QA_EMAIL'],
          password: ENV['CARALOGO_QA_PASSWORD']
        )
      )
    end

    # Confirma o sucesso e o contrato mínimo da resposta antes de armazenar o token.
    def validate_token_response!(response)
      unless response.code == 200
        raise "Falha ao obter token QA (status #{response.code}): #{sanitized_error_body(response)}"
      end

      body = response.parsed_response
      raise 'Resposta da autenticação QA não é um objeto JSON.' unless body.is_a?(Hash)

      access_token = body['accessToken']
      return if access_token.is_a?(String) && !access_token.strip.empty?

      raise 'Resposta da autenticação QA não contém accessToken.'
    rescue JSON::ParserError
      raise 'Resposta da autenticação QA não contém JSON válido.'
    end

    # Armazena os metadados do token e converte a expiração para comparação temporal.
    def store_token_data!(body)
      @access_token = body.fetch('accessToken')
      @token_type = body.fetch('tokenType')
      @expires_in = body.fetch('expiresIn')
      @expires_at = Time.parse(body.fetch('expiresAt'))
    rescue KeyError, TypeError, ArgumentError
      clear_token_data!
      raise 'Resposta da autenticação QA contém metadados de expiração inválidos.'
    end

    # Reutiliza o token somente enquanto houver margem segura antes da expiração.
    def token_valid?
      return false if @access_token.nil? || @expires_at.nil?

      Time.now < (@expires_at - EXPIRY_SAFETY_WINDOW_SECONDS)
    end

    # Remove qualquer estado parcial quando a resposta de autenticação é inválida.
    def clear_token_data!
      @access_token = nil
      @token_type = nil
      @expires_in = nil
      @expires_at = nil
    end

    # Mantém apenas campos seguros do erro e mascara valores sensíveis eventualmente refletidos.
    def sanitized_error_body(response)
      body = response.parsed_response
      return '<resposta de erro sem objeto JSON>' unless body.is_a?(Hash)

      safe_body = body.select { |key, _value| SAFE_ERROR_FIELDS.include?(key) }
      redact_sensitive_values(JSON.generate(safe_body))
    rescue JSON::ParserError
      '<body não JSON omitido por segurança>'
    end

    # Substitui credenciais do ambiente caso a API as reflita em uma mensagem de erro.
    def redact_sensitive_values(text)
      REQUIRED_ENV_VARS.reduce(text) do |sanitized_text, env_name|
        value = ENV[env_name]
        next sanitized_text if value.nil? || value.empty?

        sanitized_text.gsub(value, '[REDACTED]')
      end
    end
  end
end
