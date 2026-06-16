require 'uri'

def public_pagination_sorting_data
  caralogo_data.fetch('public_pagination_sorting')
end

def public_pagination_sorting_query(page)
  data = public_pagination_sorting_data

  URI.encode_www_form(
    page: page,
    pageSize: data.fetch('page_size'),
    sort: data.fetch('sort_name'),
    direction: data.fetch('direction_asc')
  )
end

def public_pagination_sorting_items_from(response)
  body = response.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)

  body['items']
end

def public_pagination_sorting_body
  @resposta_api.parsed_response
end

Quando('eu fizer uma requisição GET para a primeira página do catálogo ordenado por nome crescente') do
  data = public_pagination_sorting_data
  query = public_pagination_sorting_query(data.fetch('first_page'))

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a segunda página do catálogo ordenado por nome crescente') do
  data = public_pagination_sorting_data
  query = public_pagination_sorting_query(data.fetch('second_page'))

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu consultar as duas primeiras páginas do catálogo ordenado por nome crescente') do
  data = public_pagination_sorting_data
  first_page_query = public_pagination_sorting_query(data.fetch('first_page'))
  second_page_query = public_pagination_sorting_query(data.fetch('second_page'))

  @primeira_pagina_ordenada = CaralogoApi.get("/@#{@public_handle}/items?#{first_page_query}")
  @segunda_pagina_ordenada = CaralogoApi.get("/@#{@public_handle}/items?#{second_page_query}")
end

Então('devo validar os dados da primeira página ordenada') do
  data = public_pagination_sorting_data
  body = public_pagination_sorting_body

  expect(body['page']).to eq(data.fetch('first_page'))
  expect(body['pageSize']).to eq(data.fetch('page_size'))
  expect(body['totalItems']).to eq(data.fetch('expected_total_items'))
  expect(body['totalPages']).to eq(data.fetch('expected_total_pages'))
  expect(body['items']).to be_an(Array)
  expect(body['items'].length).to eq(data.fetch('page_size'))
end

Então('devo validar os dados da segunda página ordenada') do
  data = public_pagination_sorting_data
  body = public_pagination_sorting_body
  expected_second_page_items_count = data.fetch('expected_total_items') - data.fetch('page_size')

  expect(body['page']).to eq(data.fetch('second_page'))
  expect(body['pageSize']).to eq(data.fetch('page_size'))
  expect(body['totalItems']).to eq(data.fetch('expected_total_items'))
  expect(body['totalPages']).to eq(data.fetch('expected_total_pages'))
  expect(body['items']).to be_an(Array)
  expect(body['items'].length).to eq(expected_second_page_items_count)
end

Então('devo validar que os itens da resposta estão em ordem crescente por nome') do
  items = public_pagination_sorting_body.fetch('items')
  names = items.map { |item| item.fetch('name') }

  expect(names).to eq(names.sort)
end

Então('devo validar que os itens combinados das páginas estão em ordem crescente por nome') do
  expect(@primeira_pagina_ordenada.code).to eq(200)
  expect(@segunda_pagina_ordenada.code).to eq(200)

  first_page_items = public_pagination_sorting_items_from(@primeira_pagina_ordenada)
  second_page_items = public_pagination_sorting_items_from(@segunda_pagina_ordenada)
  combined_names = (first_page_items + second_page_items).map { |item| item.fetch('name') }

  expect(combined_names).not_to be_empty
  expect(combined_names).to eq(combined_names.sort)
end

Então('a resposta não deve expor campos proibidos nas páginas consultadas') do
  forbidden_fields = caralogo_data.fetch('forbidden_public_fields')

  [@primeira_pagina_ordenada, @segunda_pagina_ordenada].each do |response|
    forbidden = forbidden_fields_found(response.parsed_response, forbidden_fields)
    expect(forbidden).to be_empty
  end
end
