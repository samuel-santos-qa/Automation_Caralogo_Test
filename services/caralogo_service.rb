class CaralogoApi
  include HTTParty

  base_uri 'https://api-staging.caralogo.com.br'

  headers(
    'Content-Type' => 'application/json'
  )
end
