# Lê os tokens de share controlados para o ambiente de staging.
def share_tokens_data
  caralogo_data.fetch('share_tokens')
end

# Retorna o token válido usado para acessar o item compartilhado controlado.
def valid_share_item_token
  share_tokens_data.fetch('valid_token')
end

# Retorna o token revogado usado para validar respostas seguras de negação.
def revoked_share_item_token
  share_tokens_data.fetch('revoked_token')
end

# O endpoint de share retorna um item direto, não uma lista paginada.
def share_item_body
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)

  body
end

# Lê os dados esperados do item retornado pelo share link.
def share_item_data
  caralogo_data.fetch('share_item')
end

Dado('que eu tenha um token válido de share item configurado') do
  # Token válido acessa apenas o item compartilhado controlado em staging.
  @share_item_token = valid_share_item_token
end

Dado('que eu tenha um token revogado de share item configurado') do
  # Token revogado valida negação segura sem usar autenticação.
  @share_item_token = revoked_share_item_token
end

Quando('eu fizer uma requisição GET para o item compartilhado') do
  get_endpoint("/share/items/#{@share_item_token}")
end

Quando('eu fizer uma requisição GET para o item compartilhado revogado') do
  get_endpoint("/share/items/#{@share_item_token}")
end

Quando('eu fizer uma requisição GET para a imagem cover do item compartilhado') do
  get_endpoint("/share/items/#{@share_item_token}/images/cover")
end

Quando('eu fizer uma requisição GET para a imagem de sortOrder {int} do item compartilhado') do |sort_order|
  get_endpoint("/share/items/#{@share_item_token}/images/#{sort_order}")
end

Então('devo validar os dados públicos do item compartilhado') do
  body = share_item_body
  expected_item = share_item_data

  # Valida somente campos definidos na massa de share, separada da massa do catálogo.
  expect(body['publicId']).to eq(expected_item.fetch('publicId'))
  expect(body['slug']).to eq(expected_item.fetch('slug'))
  expect(body['name']).to eq(expected_item.fetch('name'))

  expect(body['brand']).to be_a(Hash)
  expect(body.dig('brand', 'name')).to eq(expected_item.dig('brand', 'name'))
  expect(body.dig('brand', 'slug')).to eq(expected_item.dig('brand', 'slug'))

  expect(body['category']).to be_a(Hash)
  expect(body.dig('category', 'name')).to eq(expected_item.dig('category', 'name'))
  expect(body.dig('category', 'slug')).to eq(expected_item.dig('category', 'slug'))

  expect(body['status']).to eq(expected_item.fetch('status'))
  expect(body['commercialAvailability']).to eq(expected_item.fetch('commercialAvailability'))
  expect(body['origin']).to eq(expected_item.fetch('origin'))

  expect(body['size']).to eq(expected_item.fetch('size')) if expected_item.key?('size')
  expect(body['description']).to eq(expected_item.fetch('description')) if expected_item.key?('description')
  expect(body['rating']).to eq(expected_item.fetch('rating')) if expected_item.key?('rating')
end

Então('devo validar que a resposta contém uma imagem') do
  content_type = @resposta_api.headers['content-type']

  # Share de mídia deve entregar binário de imagem, não JSON de erro.
  expect(content_type).not_to be_nil
  expect(content_type).to match(%r{\Aimage/})
  expect(@resposta_api.body).not_to be_empty
end
