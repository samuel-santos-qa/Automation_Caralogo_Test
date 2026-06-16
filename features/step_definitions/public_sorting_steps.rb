require 'time'
require 'uri'

def public_sorting_data
  caralogo_data.fetch('public_sorting')
end

def public_sorting_query(params)
  URI.encode_www_form(params)
end

def current_public_sorting_items
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items']
end

Quando('eu fizer uma requisição GET para a lista pública de itens ordenando por nome crescente') do
  sorting_data = public_sorting_data

  query = public_sorting_query(
    sort: sorting_data.fetch('sort_name'),
    direction: sorting_data.fetch('direction_asc')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens ordenando por nome decrescente') do
  sorting_data = public_sorting_data

  query = public_sorting_query(
    sort: sorting_data.fetch('sort_name'),
    direction: sorting_data.fetch('direction_desc')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens ordenando por publicação decrescente') do
  sorting_data = public_sorting_data

  query = public_sorting_query(
    sort: sorting_data.fetch('sort_published_at'),
    direction: sorting_data.fetch('direction_desc')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens com sort inválido') do
  sorting_data = public_sorting_data

  query = public_sorting_query(
    sort: sorting_data.fetch('invalid_sort'),
    direction: sorting_data.fetch('direction_asc')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens com direction inválida') do
  sorting_data = public_sorting_data

  query = public_sorting_query(
    sort: sorting_data.fetch('sort_name'),
    direction: sorting_data.fetch('invalid_direction')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Então('devo validar que os itens foram ordenados por nome crescente') do
  names = current_public_sorting_items.map { |item| item.fetch('name') }

  expect(names).to eq(names.sort)
end

Então('devo validar que os itens foram ordenados por nome decrescente') do
  names = current_public_sorting_items.map { |item| item.fetch('name') }

  expect(names).to eq(names.sort.reverse)
end

Então('devo validar que os itens foram ordenados por data de publicação decrescente') do
  published_dates = current_public_sorting_items.map { |item| Time.parse(item.fetch('publishedAt')) }

  expect(published_dates).to eq(published_dates.sort.reverse)
end

Então('devo validar a mensagem de erro para sort inválido') do
  body = @resposta_api.parsed_response
  expected_message = public_sorting_data.fetch('expected_invalid_sort_message')

  expect(body).to be_a(Hash)
  expect(body['statusCode']).to eq(400)
  expect(body['error']).to eq('Bad Request')
  expect(body['message']).to be_an(Array)
  expect(body['message'].join(' ')).to include(expected_message)
end

Então('devo validar a mensagem de erro para direction inválida') do
  body = @resposta_api.parsed_response
  expected_message = public_sorting_data.fetch('expected_invalid_direction_message')

  expect(body).to be_a(Hash)
  expect(body['statusCode']).to eq(400)
  expect(body['error']).to eq('Bad Request')
  expect(body['message']).to be_an(Array)
  expect(body['message'].join(' ')).to include(expected_message)
end
