# Retorna a lista de itens de uma resposta de taxonomia autenticada.
def authenticated_taxonomy_items(body)
  return body if body.is_a?(Array)
  return body['items'] if body.is_a?(Hash) && body['items'].is_a?(Array)

  []
end

# Lista campos técnicos que não devem aparecer nas taxonomias owner-scoped.
def authenticated_taxonomy_forbidden_fields
  %w[
    authProviderId
    auth_provider_id
    tokenHash
    token_hash
    accessToken
    access_token
    refreshToken
    refresh_token
    password
    authorization
    cookie
    storageProvider
    storage_provider
    storageKey
    storage_key
    bucket
  ]
end

# Varre recursivamente apenas chaves para localizar campos internos proibidos.
def authenticated_taxonomy_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)
      found.concat(authenticated_taxonomy_forbidden_fields_found(value, forbidden_fields))
    end
  when Array
    body.flat_map { |item| authenticated_taxonomy_forbidden_fields_found(item, forbidden_fields) }
  else
    []
  end.uniq
end

Quando('eu fizer uma requisição GET autenticada para a taxonomia {string}') do |endpoint|
  get_authenticated_endpoint(endpoint)
end

Então('devo validar o contrato da resposta de taxonomia autenticada') do
  body = @resposta_api.parsed_response

  valid_body = body.is_a?(Hash) || body.is_a?(Array)
  expect(valid_body).to be(true),
                        'Resposta da taxonomia autenticada deve ser um objeto ou uma lista'

  if body.is_a?(Hash) && body.key?('items')
    expect(body['items']).to be_an(Array),
                             'Campo items da taxonomia autenticada deve ser uma lista'
  end

  authenticated_taxonomy_items(body).each_with_index do |item, index|
    expect(item).to be_a(Hash), "Item #{index} da taxonomia autenticada deve ser um objeto"

    business_keys = %w[id name slug].select { |key| item.key?(key) }
    expect(business_keys).not_to be_empty,
                                 "Item #{index} deve possuir ao menos id, name ou slug"
  end
end

Então('a resposta autenticada de taxonomia não deve expor campos internos proibidos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_taxonomy_forbidden_fields
  found = authenticated_taxonomy_forbidden_fields_found(body, forbidden_fields)

  expect(found).to be_empty,
                   "Campos internos proibidos encontrados na taxonomia: #{found.join(', ')}"
end
