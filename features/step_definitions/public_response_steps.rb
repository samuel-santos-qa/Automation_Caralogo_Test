# Lê os dados do perfil público usado como base nos cenários.
def public_profile_data
  caralogo_data.fetch('public_profile')
end

# Lê os dados do item público usado nas validações de catálogo, detalhe e mídia.
def public_item_data
  caralogo_data.fetch('public_item')
end

# Converte a resposta em JSON quando possível, mantendo body bruto para respostas não JSON.
def parsed_response_body
  @resposta_api.parsed_response
rescue JSON::ParserError
  @resposta_api.body
end

# Localiza o item base dentro de respostas paginadas do catálogo público.
def public_item_from_catalog_response
  body = @resposta_api.parsed_response
  item_data = public_item_data

  body.fetch('items').find { |item| item['publicId'] == item_data.fetch('public_id') }
end

# Varre Hashes, Arrays e Strings para detectar vazamento de campos proibidos em qualquer nível.
def forbidden_fields_found(body, forbidden_fields)
  found = []

  case body
  when Hash
    body.each do |key, value|
      found << key if forbidden_fields.include?(key)
      found.concat(forbidden_fields_found(value, forbidden_fields))
    end
  when Array
    body.each do |item|
      found.concat(forbidden_fields_found(item, forbidden_fields))
    end
  when String
    # Respostas não JSON também são verificadas para evitar vazamento em texto bruto.
    forbidden_fields.each do |field|
      found << field if body.include?(field)
    end
  end

  found.uniq
end

Dado('que eu tenha um handle público válido') do
  @public_handle = public_profile_data.fetch('handle')
end

Dado('que eu tenha um item público válido') do
  @public_handle = public_profile_data.fetch('handle')
  @public_item = public_item_data
end

Quando('eu fizer uma requisição GET para o perfil público') do
  get_endpoint("/@#{@public_handle}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens') do
  get_endpoint("/@#{@public_handle}/items")
end

Quando('eu fizer uma requisição GET para as opções públicas de filtro') do
  get_endpoint("/@#{@public_handle}/filter-options")
end

Quando('eu fizer uma requisição GET para o detalhe público do item') do
  handle = public_profile_data.fetch('handle')
  slug_with_public_id = public_item_data.fetch('slug_with_public_id')

  get_endpoint("/@#{handle}/items/#{slug_with_public_id}")
end

Então('devo validar que o catálogo público possui o item esperado') do
  body = @resposta_api.parsed_response
  item_data = public_item_data

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  item = body['items'].find { |catalog_item| catalog_item['publicId'] == item_data.fetch('public_id') }

  expect(item).not_to be_nil, 'Item público esperado não foi encontrado no catálogo'
end

Então('devo validar os dados resumidos do item público') do
  item = public_item_from_catalog_response
  item_data = public_item_data

  expect(item).not_to be_nil

  expect(item['name']).to eq(item_data.fetch('name'))
  expect(item['slug']).to eq(item_data.fetch('slug'))
  expect(item['publicId']).to eq(item_data.fetch('public_id'))
  expect(item['status']).to eq(item_data.fetch('status'))
  expect(item['size']).to eq(item_data.fetch('size'))
  expect(item['commercialAvailability']).to eq(item_data.fetch('commercial_availability'))
  expect(item['origin']).to eq(item_data.fetch('origin'))
  expect(item['rating']).to eq(item_data.fetch('rating'))

  expect(item['brand']).to be_a(Hash)
  expect(item['brand']['name']).to eq(item_data.fetch('brand_name'))
  expect(item['brand']['slug']).to eq(item_data.fetch('brand_slug'))

  expect(item['coverImage']).to be_a(Hash)
  expect(item['coverImage']['url']).to eq(item_data.fetch('cover_image_url'))
  expect(item['coverImage']['width']).to eq(item_data.fetch('cover_image_width'))
  expect(item['coverImage']['height']).to eq(item_data.fetch('cover_image_height'))
  expect(item['coverImage']['sortOrder']).to eq(item_data.fetch('cover_image_sort_order'))
  expect(item['coverImage']['isCover']).to eq(item_data.fetch('cover_image_is_cover'))
end

Então('devo validar os dados detalhados do item público') do
  body = @resposta_api.parsed_response
  item_data = public_item_data

  expect(body).to be_a(Hash)
  expect(body['name']).to eq(item_data.fetch('name'))
  expect(body['slug']).to eq(item_data.fetch('slug'))
  expect(body['publicId']).to eq(item_data.fetch('public_id'))

  # Campos opcionais públicos só são validados quando a API os retorna.
  expect(body['status']).to eq(item_data.fetch('status')) if body.key?('status')
  expect(body['size']).to eq(item_data.fetch('size')) if body.key?('size')
  expect(body['description']).to eq(item_data.fetch('description')) if body.key?('description')
  expect(body['commercialAvailability']).to eq(item_data.fetch('commercial_availability')) if body.key?('commercialAvailability')
  expect(body['origin']).to eq(item_data.fetch('origin')) if body.key?('origin')
  expect(body['rating']).to eq(item_data.fetch('rating')) if body.key?('rating')
end

Então('a resposta não deve expor campos proibidos') do
  forbidden_fields = caralogo_data.fetch('forbidden_public_fields')
  found = forbidden_fields_found(parsed_response_body, forbidden_fields)

  # A mesma validação cobre sucesso, erro seguro e respostas não JSON.
  expect(found).to be_empty, "Campos proibidos encontrados na resposta: #{found.join(', ')}"
end
