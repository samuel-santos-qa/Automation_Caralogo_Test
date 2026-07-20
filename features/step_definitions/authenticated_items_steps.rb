# Lista os campos obrigatórios do contrato owner-scoped de item.
def authenticated_owner_item_required_fields
  %w[
    id
    publicId
    slug
    name
    brand
    catalogProduct
    catalogVariant
    catalogMeasurementSnapshot
    status
    size
    category
    collections
    tags
    description
    measurementsText
    measurements
    badges
    origin
    commercialAvailability
    rating
    favorite
    privateNotes
    purchasePrice
    purchaseCurrency
    purchaseDate
    purchaseVendor
    purchaseLink
    purchaseNotes
    visibility
    fieldVisibility
    publishedAt
    createdAt
    updatedAt
  ]
end

# Lista campos técnicos que não devem aparecer na resposta autenticada de itens.
def authenticated_owner_item_forbidden_fields
  %w[
    profileId
    profile_id
    authProviderId
    auth_provider_id
    deletedAt
    deleted_at
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
    originalFilename
    original_filename
  ]
end

# Varre recursivamente apenas chaves para localizar campos internos proibidos.
def authenticated_owner_item_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)
      found.concat(
        authenticated_owner_item_forbidden_fields_found(value, forbidden_fields)
      )
    end
  when Array
    body.flat_map do |item|
      authenticated_owner_item_forbidden_fields_found(item, forbidden_fields)
    end
  else
    []
  end.uniq
end

Quando('eu fizer uma requisição GET autenticada para meus itens') do
  get_authenticated_endpoint('/me/items')
end

Então('devo validar o contrato da paginação dos itens autenticados') do
  body = @resposta_api.parsed_response
  required_fields = %w[page pageSize totalItems totalPages items]

  expect(body).to be_a(Hash)
  required_fields.each do |field|
    expect(body).to have_key(field), "Campo obrigatório ausente na paginação: #{field}"
  end

  %w[page pageSize totalItems totalPages].each do |field|
    expect(body[field]).to be_a(Integer), "Campo #{field} deve ser um Integer"
  end

  expect(body['page']).to be >= 1
  expect(body['pageSize']).to be >= 1
  expect(body['totalItems']).to be >= 0
  expect(body['totalPages']).to be >= 0
  expect(body['items']).to be_an(Array)
  expect(body['items'].length).to be <= body['pageSize']
end

Então('devo validar o contrato dos itens autenticados retornados') do
  body = @resposta_api.parsed_response

  body.fetch('items').each_with_index do |item, index|
    expect(item).to be_a(Hash), "Item #{index} deve ser um objeto"

    authenticated_owner_item_required_fields.each do |field|
      expect(item).to have_key(field), "Campo obrigatório ausente no item #{index}: #{field}"
    end

    %w[id publicId slug name].each do |field|
      expect(item[field]).to be_a(String), "Campo #{field} do item #{index} deve ser String"
      expect(item[field].strip).not_to be_empty, "Campo #{field} do item #{index} não pode ser vazio"
    end

    %w[collections tags measurements badges].each do |field|
      expect(item[field]).to be_an(Array), "Campo #{field} do item #{index} deve ser Array"
    end

    expect([true, false]).to include(item['favorite'])
    expect(item['fieldVisibility']).to be_a(Hash)
  end
end

Então('a resposta autenticada de itens não deve expor campos internos proibidos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_owner_item_forbidden_fields
  found = authenticated_owner_item_forbidden_fields_found(body, forbidden_fields)

  expect(found).to be_empty,
                   "Campos internos proibidos encontrados nos itens: #{found.join(', ')}"
end
