require 'time'

# Lista os campos obrigatórios dos metadados de um token de compartilhamento.
def authenticated_share_token_required_fields
  %w[
    id
    status
    createdAt
    revokedAt
  ]
end

# Lista chaves sensíveis ou internas proibidas na resposta owner-safe.
def authenticated_share_token_forbidden_fields
  %w[
    token
    rawToken
    raw_token
    shareToken
    share_token
    tokenHash
    token_hash
    secret
    shareUrl
    share_url
    profileId
    profile_id
    authProviderId
    auth_provider_id
    accessToken
    access_token
    refreshToken
    refresh_token
    authorization
    password
    cookie
    deletedAt
    deleted_at
  ]
end

# Varre recursivamente apenas chaves para localizar campos sensíveis proibidos.
def authenticated_share_token_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)
      found.concat(
        authenticated_share_token_forbidden_fields_found(value, forbidden_fields)
      )
    end
  when Array
    body.flat_map do |item|
      authenticated_share_token_forbidden_fields_found(item, forbidden_fields)
    end
  else
    []
  end.uniq
end

# Confirma o formato UUID sem incluir o identificador em mensagens de falha.
def authenticated_share_token_uuid?(value)
  value.is_a?(String) &&
    value.match?(
      /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    )
end

# Confirma o formato date-time sem expor o valor validado em caso de erro.
def authenticated_share_token_datetime?(value)
  return false unless value.is_a?(String) && !value.strip.empty?

  Time.iso8601(value)
  true
rescue ArgumentError
  false
end

Dado('que eu tenha um item autenticado controlado com histórico de compartilhamento') do
  get_authenticated_endpoint('/me/items?page=1&pageSize=100')

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar os itens autenticados'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  expected_public_id = share_item_data.fetch('publicId')
  selected_item = body['items'].find do |item|
    item['publicId'] == expected_public_id
  end

  expect(selected_item).not_to be_nil,
                               'O item controlado com histórico de compartilhamento não foi encontrado'

  expect(selected_item).to have_key('id'),
                            'O item compartilhado não possui o campo obrigatório id'

  @authenticated_share_item_id = selected_item['id']

  expect(@authenticated_share_item_id).to be_a(String)
  expect(@authenticated_share_item_id.strip).not_to be_empty
end

Quando('eu consultar os tokens de compartilhamento desse item autenticado') do
  get_authenticated_endpoint(
    "/me/items/#{@authenticated_share_item_id}/share-tokens"
  )
end

Então('devo validar o contrato da lista autenticada de tokens de compartilhamento') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
end

Então('a lista autenticada de tokens de compartilhamento não deve estar vazia') do
  metadata = @resposta_api.parsed_response.fetch('items')

  expect(metadata).not_to be_empty,
                          'O item controlado deveria possuir histórico de compartilhamento'
end

Então('devo validar os metadados dos tokens de compartilhamento retornados') do
  metadata = @resposta_api.parsed_response.fetch('items')

  metadata.each_with_index do |share_token, index|
    expect(share_token).to be_a(Hash),
                             "Metadado de compartilhamento #{index} deve ser um objeto"

    authenticated_share_token_required_fields.each do |field|
      expect(share_token).to have_key(field),
                              "Campo obrigatório ausente no metadado #{index}: #{field}"
    end

    expect(authenticated_share_token_uuid?(share_token['id'])).to be(true),
                                                                  "Campo id do metadado #{index} deve ser um UUID válido"

    expect(%w[active revoked]).to include(share_token['status']),
                                   "Status inválido no metadado #{index}"

    expect(authenticated_share_token_datetime?(share_token['createdAt'])).to be(true),
                                                                            "Campo createdAt do metadado #{index} deve ser um date-time válido"

    next if share_token['revokedAt'].nil?

    expect(authenticated_share_token_datetime?(share_token['revokedAt'])).to be(true),
                                                                            "Campo revokedAt do metadado #{index} deve ser nil ou um date-time válido"
  end
end

Então('a resposta autenticada não deve expor tokens ou segredos de compartilhamento') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_share_token_forbidden_fields
  found = authenticated_share_token_forbidden_fields_found(body, forbidden_fields)

  expect(found).to be_empty,
                   "Chaves sensíveis encontradas na resposta: #{found.join(', ')}"
end
