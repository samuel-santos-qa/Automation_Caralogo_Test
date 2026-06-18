# Lê a massa YAML dos itens usados para validar field visibility.
def field_visibility_data
  caralogo_data.fetch('field_visibility')
end

# Lê o item de controle que deve expor campos públicos configurados como visíveis.
def visible_field_item_data
  field_visibility_data.fetch('visible_item')
end

# Lê o item de controle que deve ocultar campos configurados como privados.
def hidden_field_item_data
  field_visibility_data.fetch('hidden_item')
end

# Retorna itens da resposta atual após validar o contrato mínimo de catálogo paginado.
def catalog_items_from_response
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)

  body['items']
end

# Busca um item específico na lista pública pelo publicId.
def catalog_item_by_public_id(public_id)
  catalog_items_from_response.find { |item| item['publicId'] == public_id }
end

# Campos ocultos devem estar ausentes, não apenas com valor nil.
def expect_fields_absent(hash, fields)
  fields.each do |field|
    expect(hash).not_to have_key(field), "Campo #{field} não deveria aparecer na resposta pública"
  end
end

Dado('que eu tenha um item público com campos visíveis') do
  @public_handle = public_profile_data.fetch('handle')
  @visibility_item = visible_field_item_data
end

Dado('que eu tenha um item público com campos ocultos') do
  @public_handle = public_profile_data.fetch('handle')
  @visibility_item = hidden_field_item_data
end

Quando('eu fizer uma requisição GET para o detalhe público do item de visibilidade') do
  handle = public_profile_data.fetch('handle')
  slug_with_public_id = @visibility_item.fetch('slug_with_public_id')

  get_endpoint("/@#{handle}/items/#{slug_with_public_id}")
end

Então('devo validar que o item com campos públicos visíveis aparece no catálogo') do
  item_data = visible_field_item_data
  item = catalog_item_by_public_id(item_data.fetch('public_id'))

  expect(item).not_to be_nil, 'Item com campos públicos visíveis não foi encontrado no catálogo'
  expect(item['name']).to eq(item_data.fetch('name'))
  expect(item['slug']).to eq(item_data.fetch('slug'))
end

Então('devo validar que description e rating aparecem no item público visível') do
  item_data = visible_field_item_data
  item = catalog_item_by_public_id(item_data.fetch('public_id'))

  expect(item).not_to be_nil
  expect(item).to have_key('description')
  expect(item).to have_key('rating')
  expect(item['description']).to eq(item_data.fetch('description'))
  expect(item['rating']).to eq(item_data.fetch('rating'))
end

Então('devo validar que o item com campos ocultos aparece no catálogo') do
  item_data = hidden_field_item_data
  item = catalog_item_by_public_id(item_data.fetch('public_id'))

  expect(item).not_to be_nil, 'Item com campos ocultos não foi encontrado no catálogo'
  expect(item['name']).to eq(item_data.fetch('name'))
  expect(item['slug']).to eq(item_data.fetch('slug'))
end

Então('devo validar que description e rating não aparecem no item com campos ocultos') do
  item_data = hidden_field_item_data
  item = catalog_item_by_public_id(item_data.fetch('public_id'))

  expect(item).not_to be_nil
  expect_fields_absent(item, item_data.fetch('hidden_fields'))
end

Então('devo validar que o detalhe público contém description e rating') do
  body = @resposta_api.parsed_response
  item_data = visible_field_item_data

  expect(body).to be_a(Hash)
  expect(body['publicId']).to eq(item_data.fetch('public_id'))
  expect(body['name']).to eq(item_data.fetch('name'))
  expect(body).to have_key('descriptions')
  expect(body).to have_key('rating')
  expect(body['description']).to eq(item_data.fetch('description'))
  expect(body['rating']).to eq(item_data.fetch('rating'))
end

Então('devo validar que o detalhe público não contém description e rating') do
  body = @resposta_api.parsed_response
  item_data = hidden_field_item_data

  expect(body).to be_a(Hash)
  expect(body['publicId']).to eq(item_data.fetch('public_id'))
  expect(body['name']).to eq(item_data.fetch('name'))
  expect_fields_absent(body, item_data.fetch('hidden_fields'))
end
