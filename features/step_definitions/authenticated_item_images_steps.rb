# Lista os campos obrigatórios de uma imagem owner-scoped.
def authenticated_owner_image_required_fields
  %w[
    id
    url
    altText
    width
    height
    byteSize
    mimeType
    sortOrder
    processingStatus
    isCover
    createdAt
    updatedAt
  ]
end

# Lista campos internos que não devem aparecer nas respostas owner-safe de imagens.
def authenticated_owner_image_forbidden_fields
  %w[
    profileId
    profile_id
    authProviderId
    auth_provider_id
    storageProvider
    storage_provider
    storageKey
    storage_key
    bucket
    originalFilename
    original_filename
    tokenHash
    token_hash
    accessToken
    access_token
    refreshToken
    refresh_token
    password
    authorization
    cookie
    deletedAt
    deleted_at
  ]
end

# Varre recursivamente apenas chaves para localizar campos internos proibidos.
def authenticated_owner_image_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)
      found.concat(
        authenticated_owner_image_forbidden_fields_found(value, forbidden_fields)
      )
    end
  when Array
    body.flat_map do |item|
      authenticated_owner_image_forbidden_fields_found(item, forbidden_fields)
    end
  else
    []
  end.uniq
end

Dado('que eu tenha o item autenticado controlado com imagem') do
  get_authenticated_endpoint('/me/items?page=1&pageSize=24')

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar os itens autenticados'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  expected_item = public_item_data
  expected_public_id = expected_item.fetch('public_id')

  selected_item = body['items'].find do |item|
    item['publicId'] == expected_public_id
  end

  expect(selected_item).not_to be_nil,
                               'O item controlado com imagem não foi encontrado em /me/items'

  expect(selected_item).to have_key('id'),
                            'O item controlado não possui o campo obrigatório id'

  @authenticated_owner_item_id = selected_item['id']

  expect(@authenticated_owner_item_id).to be_a(String)
  expect(@authenticated_owner_item_id.strip).not_to be_empty
end

Dado('que eu tenha uma imagem autenticada pronta desse item') do
  get_authenticated_endpoint(
    "/me/items/#{@authenticated_owner_item_id}/images"
  )

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar as imagens do item autenticado'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  selected_image = body['items'].find do |image|
    image['processingStatus'] == 'ready'
  end

  expect(selected_image).not_to be_nil,
                                'Nenhuma imagem pronta foi encontrada no item autenticado controlado'

  expect(selected_image).to have_key('id'),
                             'A imagem pronta não possui o campo obrigatório id'

  @authenticated_owner_image_id = selected_image['id']

  expect(@authenticated_owner_image_id).to be_a(String)
  expect(@authenticated_owner_image_id.strip).not_to be_empty
end

Quando('eu consultar as imagens desse item autenticado') do
  get_authenticated_endpoint(
    "/me/items/#{@authenticated_owner_item_id}/images"
  )
end

Quando('eu consultar o arquivo dessa imagem autenticada') do
  get_authenticated_endpoint(
    "/me/items/#{@authenticated_owner_item_id}/images/#{@authenticated_owner_image_id}/file"
  )
end

Então('devo validar o contrato da lista de imagens autenticadas') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
end

Então('a lista de imagens autenticadas deve possuir pelo menos três imagens') do
  images = @resposta_api.parsed_response.fetch('items')

  expect(images.length).to be >= 3,
                           'O item controlado deve possuir pelo menos três imagens para validar a ordenação'
end

Então('devo validar o contrato das imagens autenticadas retornadas') do
  images = @resposta_api.parsed_response.fetch('items')

  images.each_with_index do |image, index|
    expect(image).to be_a(Hash), "Imagem #{index} deve ser um objeto"

    authenticated_owner_image_required_fields.each do |field|
      expect(image).to have_key(field),
                       "Campo obrigatório ausente na imagem #{index}: #{field}"
    end

    %w[id url mimeType createdAt updatedAt].each do |field|
      expect(image[field]).to be_a(String),
                               "Campo #{field} da imagem #{index} deve ser String"
      expect(image[field].strip).not_to be_empty,
                                     "Campo #{field} da imagem #{index} não pode ser vazio"
    end

    expect(image['sortOrder']).to be_a(Numeric)
    expect(image['sortOrder']).to be >= 0

    expect(image['byteSize']).to be_a(Numeric)
    expect(image['byteSize']).to be >= 0

    expect(%w[pending processing ready failed]).to include(image['processingStatus'])
    expect([true, false]).to include(image['isCover'])

    expect(image['altText']).to be_a(String) unless image['altText'].nil?

    %w[width height].each do |field|
      next if image[field].nil?

      expect(image[field]).to be_a(Numeric)
      expect(image[field]).to be > 0
    end
  end
end

Então('as imagens autenticadas devem estar na ordem esperada') do
  images = @resposta_api.parsed_response.fetch('items')
  current_order = images.map { |image| [image['sortOrder'], image['id']] }

  expect(current_order).to eq(current_order.sort),
                           'As imagens não estão ordenadas por sortOrder e id'
end

Então('a resposta autenticada de imagens não deve expor campos internos proibidos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_owner_image_forbidden_fields
  found = authenticated_owner_image_forbidden_fields_found(body, forbidden_fields)

  expect(found).to be_empty,
                   "Campos internos proibidos encontrados nas imagens: #{found.join(', ')}"
end

Então('devo validar que a resposta é uma imagem WebP autenticada') do
  content_type = @resposta_api.headers['content-type']

  expect(content_type).not_to be_nil,
                              'Header Content-Type ausente na resposta da imagem autenticada'

  expect(content_type).to start_with('image/webp'),
                          "Content-Type inesperado para imagem autenticada: #{content_type}"
end

Então('devo validar que o arquivo da imagem autenticada não está vazio') do
  expect(@resposta_api.body).not_to be_nil
  expect(@resposta_api.body.bytesize).to be > 0
end

Então('devo validar o cache privado da imagem autenticada') do
  cache_control = @resposta_api.headers['cache-control']

  expect(cache_control).not_to be_nil,
                                'Header Cache-Control ausente na resposta da imagem autenticada'

  expect(cache_control).to include('private')
  expect(cache_control).to include('max-age=300')
end
