# Lista os campos obrigatórios da resposta de permissões administrativas.
def authenticated_catalog_permission_required_fields
  %w[
    isAdmin
    roles
    source
  ]
end

# Retorna as roles administrativas declaradas no OpenAPI.
def authenticated_catalog_permission_role_values
  %w[
    catalog_admin
    owner
  ]
end

# Retorna as origens de permissão declaradas no OpenAPI.
def authenticated_catalog_permission_source_values
  %w[
    env
    grant
    none
  ]
end

# Lista dados internos ou sensíveis que não devem aparecer na resposta de permissões.
def authenticated_catalog_permission_forbidden_fields
  %w[
    authProviderId
    auth_provider_id
    email
    password
    token
    tokenHash
    token_hash
    accessToken
    access_token
    refreshToken
    refresh_token
    authorization
    cookie
    secret
    clientSecret
    client_secret
  ]
end

# Varre recursivamente apenas chaves para localizar dados internos proibidos.
def authenticated_catalog_permission_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)

      found.concat(
        authenticated_catalog_permission_forbidden_fields_found(
          value,
          forbidden_fields
        )
      )
    end
  when Array
    body.flat_map do |item|
      authenticated_catalog_permission_forbidden_fields_found(
        item,
        forbidden_fields
      )
    end
  else
    []
  end.uniq
end

Quando('eu consultar minhas permissões administrativas do catálogo') do
  get_authenticated_endpoint('/admin/catalog/permissions')
end

Então('devo validar o contrato das permissões administrativas do catálogo') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)

  authenticated_catalog_permission_required_fields.each do |field|
    expect(body).to have_key(field),
                    "Campo obrigatório ausente nas permissões administrativas: #{field}"
  end

  expect([true, false]).to include(body['isAdmin']),
                              'Campo isAdmin deve ser booleano'

  expect(body['roles']).to be_an(Array),
                            'Campo roles deve ser Array'

  expect(body['source']).to be_a(String),
                             'Campo source deve ser String'

  expect(body['source'].strip).not_to be_empty,
                                   'Campo source não pode ser vazio'
end

Então('devo validar as roles administrativas retornadas') do
  roles = @resposta_api.parsed_response.fetch('roles')
  allowed_roles = authenticated_catalog_permission_role_values

  roles.each_with_index do |role, index|
    expect(role).to be_a(String),
                    "Role #{index} deve ser String"

    expect(role.strip).not_to be_empty,
                          "Role #{index} não pode ser vazia"

    expect(allowed_roles).to include(role),
                              "Role inválida na posição #{index}"
  end
end

Então('devo validar a origem das permissões administrativas') do
  source = @resposta_api.parsed_response.fetch('source')

  expect(
    authenticated_catalog_permission_source_values
  ).to include(source),
       'Origem de permissão administrativa inválida'
end

Então('a resposta de permissões não deve expor dados internos de autenticação') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_catalog_permission_forbidden_fields

  found = authenticated_catalog_permission_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos internos proibidos encontrados na resposta de permissões: #{found.join(', ')}"
end
