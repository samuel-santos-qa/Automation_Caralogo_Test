require 'uri'

# Lê a massa YAML de páginas válidas sintaticamente, mas fora do range.
def public_pagination_out_of_range_data
  caralogo_data.fetch('public_pagination_out_of_range')
end

# Monta query string para páginas além do range sem transformar o caso em erro de sintaxe.
def public_pagination_out_of_range_query(page, page_size)
  URI.encode_www_form(
    page: page,
    pageSize: page_size
  )
end

# Mesmo fora do range, a API deve manter o contrato de catálogo paginado.
def public_pagination_out_of_range_body
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)

  body
end

Quando('eu fizer uma requisição GET para uma página pública imediatamente após a última página disponível') do
  data = public_pagination_out_of_range_data
  query = public_pagination_out_of_range_query(
    data.fetch('page_after_last'),
    data.fetch('page_after_last_page_size')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para uma página pública muito acima do total de páginas') do
  data = public_pagination_out_of_range_data
  query = public_pagination_out_of_range_query(
    data.fetch('very_high_page'),
    data.fetch('very_high_page_size')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Então('devo validar que a página fora do range retornou catálogo vazio') do
  data = public_pagination_out_of_range_data
  body = public_pagination_out_of_range_body

  expect(body['page']).to eq(data.fetch('page_after_last'))
  expect(body['pageSize']).to eq(data.fetch('page_after_last_page_size'))
  expect(body['totalItems']).to eq(data.fetch('page_after_last_expected_total_items'))
  expect(body['totalPages']).to eq(data.fetch('page_after_last_expected_total_pages'))
  expect(body['items']).to eq([])
end

Então('devo validar que a página muito acima do range retornou catálogo vazio') do
  data = public_pagination_out_of_range_data
  body = public_pagination_out_of_range_body

  expect(body['page']).to eq(data.fetch('very_high_page'))
  expect(body['pageSize']).to eq(data.fetch('very_high_page_size'))
  expect(body['totalItems']).to eq(data.fetch('very_high_expected_total_items'))
  expect(body['totalPages']).to eq(data.fetch('very_high_expected_total_pages'))
  expect(body['items']).to eq([])
end
