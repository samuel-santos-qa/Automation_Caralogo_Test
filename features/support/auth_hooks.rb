require_relative 'auth_session'

BeforeAll do
  AuthSession.fetch_token! if ENV['CARALOGO_AUTH_ENABLED'] == 'true'
end
