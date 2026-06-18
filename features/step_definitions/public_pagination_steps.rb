# Lê a massa YAML de paginação pública padrão e casos inválidos.
def public_pagination_data
  caralogo_data.fetch('public_pagination')
end

Quando('eu fizer uma requisição GET para a lista pública de itens com paginação válida') do
  handle = public_profile_data.fetch('handle')
  pagination = public_pagination_data

  # Paginação válida deve retornar catálogo paginado, não erro de contrato.
  get_endpoint("/@#{handle}/items?page=#{pagination.fetch('valid_page')}&pageSize=#{pagination.fetch('valid_page_size')}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens com paginação inválida {string}') do |query|
  handle = public_profile_data.fetch('handle')

  get_endpoint("/@#{handle}/items?#{query}")
end

Então('devo validar os dados de paginação pública') do
  body = @resposta_api.parsed_response
  pagination = public_pagination_data

  # Confere o contrato mínimo de paginação sem depender da quantidade atual de itens.
  expect(body).to be_a(Hash)
  expect(body).to have_key('page')
  expect(body).to have_key('pageSize')
  expect(body).to have_key('totalItems')
  expect(body).to have_key('totalPages')
  expect(body).to have_key('items')

  expect(body['page']).to eq(pagination.fetch('valid_page'))
  expect(body['pageSize']).to eq(pagination.fetch('valid_page_size'))
  expect(body['items']).to be_an(Array)
end
