# Faz uma requisição GET autenticada usando o token QA carregado pela AuthSession.
def get_authenticated_endpoint(endpoint)
  @resposta_api = CaralogoApi.get(
    endpoint,
    headers: AuthSession.auth_headers
  )
end

# Lista os campos mínimos definidos pelo contrato OpenAPI do perfil autenticado.
def authenticated_profile_required_fields
  %w[
    handle
    displayName
    bio
    avatarUrl
    avatarAltText
    bannerUrl
    bannerAltText
    visibility
    showFollowersCount
    showFollowingCount
    preferredLocale
    createdAt
    updatedAt
  ]
end

# Lista campos internos que nunca devem aparecer na resposta do perfil autenticado.
def authenticated_profile_forbidden_fields
  %w[
    id
    profileId
    authProviderId
    email
    password
    accessToken
    refreshToken
    authorization
    cookie
  ]
end

# Varre somente chaves JSON para evitar falsos positivos em textos legítimos do perfil.
def authenticated_profile_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)
      found.concat(authenticated_profile_forbidden_fields_found(value, forbidden_fields))
    end
  when Array
    body.flat_map { |item| authenticated_profile_forbidden_fields_found(item, forbidden_fields) }
  else
    []
  end.uniq
end

Dado('que eu tenha autenticação QA habilitada') do
  AuthSession.fetch_token!
end

Quando('eu fizer uma requisição GET autenticada para o meu perfil') do
  get_authenticated_endpoint('/me/profile')
end

Então('devo validar o contrato do perfil autenticado') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  authenticated_profile_required_fields.each do |field|
    expect(body).to have_key(field), "Campo obrigatório ausente no perfil autenticado: #{field}"
  end
end

Então('a resposta autenticada não deve expor campos internos proibidos') do
  body = @resposta_api.parsed_response
  found = authenticated_profile_forbidden_fields_found(body, authenticated_profile_forbidden_fields)

  expect(found).to be_empty, "Campos internos proibidos encontrados na resposta: #{found.join(', ')}"
end
