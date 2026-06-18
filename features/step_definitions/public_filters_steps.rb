# Lê a massa YAML dos filtros públicos de brand, category, collection e tags.
def public_filters_data
  caralogo_data.fetch('public_filters')
end

# Monta o endpoint do catálogo público mantendo o handle e variando apenas a query.
def public_items_endpoint_with_query(query)
  handle = public_profile_data.fetch('handle')

  "/@#{handle}/items?#{query}"
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por brandSlug válido') do
  handle = public_profile_data.fetch('handle')
  brand_slug = public_filters_data.fetch('valid_brand_slug')

  get_endpoint("/@#{handle}/items?brandSlug=#{brand_slug}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por brandSlug inexistente') do
  handle = public_profile_data.fetch('handle')
  brand_slug = public_filters_data.fetch('invalid_brand_slug')

  get_endpoint("/@#{handle}/items?brandSlug=#{brand_slug}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por categorySlug válido') do
  category_slug = public_filters_data.fetch('valid_category_slug')

  get_endpoint(public_items_endpoint_with_query("categorySlug=#{category_slug}"))
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por categorySlug inexistente') do
  category_slug = public_filters_data.fetch('invalid_category_slug')

  get_endpoint(public_items_endpoint_with_query("categorySlug=#{category_slug}"))
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por collectionSlug válido') do
  collection_slug = public_filters_data.fetch('valid_collection_slug')

  get_endpoint(public_items_endpoint_with_query("collectionSlug=#{collection_slug}"))
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por collectionSlug inexistente') do
  collection_slug = public_filters_data.fetch('invalid_collection_slug')

  get_endpoint(public_items_endpoint_with_query("collectionSlug=#{collection_slug}"))
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por tagSlugs válido') do
  tag_slug = public_filters_data.fetch('valid_tag_slug')

  get_endpoint(public_items_endpoint_with_query("tagSlugs=#{tag_slug}"))
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por múltiplos tagSlugs válidos') do
  tag_slugs = public_filters_data.fetch('valid_tag_slugs')

  get_endpoint(public_items_endpoint_with_query("tagSlugs=#{tag_slugs}"))
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por tagSlugs inexistente') do
  tag_slug = public_filters_data.fetch('invalid_tag_slug')

  get_endpoint(public_items_endpoint_with_query("tagSlugs=#{tag_slug}"))
end

Quando('eu fizer uma requisição GET para a lista pública de itens combinando filtros válidos') do
  filters = public_filters_data

  # Combina filtros públicos na mesma query para validar interseção de critérios.
  query = [
    "brandSlug=#{filters.fetch('valid_brand_slug')}",
    "categorySlug=#{filters.fetch('valid_category_slug')}",
    "collectionSlug=#{filters.fetch('valid_collection_slug')}",
    "tagSlugs=#{filters.fetch('valid_tag_slug')}"
  ].join('&')

  get_endpoint(public_items_endpoint_with_query(query))
end

Então('devo validar que as opções públicas de filtro possuem brand, category, collection e tags esperadas') do
  body = @resposta_api.parsed_response
  filters = public_filters_data

  expect(body).to be_a(Hash)
  expect(body).to have_key('brands')
  expect(body).to have_key('categories')
  expect(body).to have_key('collections')
  expect(body).to have_key('tags')

  expect(body['brands']).to be_an(Array)
  expect(body['categories']).to be_an(Array)
  expect(body['collections']).to be_an(Array)
  expect(body['tags']).to be_an(Array)

  brand = body['brands'].find { |item| item['slug'] == filters.fetch('valid_brand_slug') }
  category = body['categories'].find { |item| item['slug'] == filters.fetch('valid_category_slug') }
  collection = body['collections'].find { |item| item['slug'] == filters.fetch('valid_collection_slug') }

  expect(brand).not_to be_nil, 'Brand esperada não encontrada em filter-options'
  expect(category).not_to be_nil, 'Category esperada não encontrada em filter-options'
  expect(collection).not_to be_nil, 'Collection esperada não encontrada em filter-options'

  expect(brand['name']).to eq(filters.fetch('expected_brand_name')) if brand.key?('name')
  expect(category['name']).to eq(filters.fetch('expected_category_name')) if category.key?('name')
  expect(collection['name']).to eq(filters.fetch('expected_collection_name')) if collection.key?('name')

  expect(brand['count']).to be > 0 if brand.key?('count')
  expect(category['count']).to be > 0 if category.key?('count')
  expect(collection['count']).to be > 0 if collection.key?('count')

  returned_tags = body['tags']
  returned_tag_slugs = returned_tags.map { |tag| tag['slug'] }

  filters.fetch('expected_tag_slugs').each do |expected_slug|
    expect(returned_tag_slugs).to include(expected_slug)
  end
end

Então('devo validar que todos os itens retornados pertencem à brand esperada') do
  body = @resposta_api.parsed_response
  expected_brand_slug = public_filters_data.fetch('valid_brand_slug')

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |item|
    expect(item).to have_key('brand')
    expect(item['brand']).to be_a(Hash)
    expect(item['brand']['slug']).to eq(expected_brand_slug)
  end
end

Então('devo validar que todos os itens retornados pertencem à category esperada quando a category estiver presente na resposta') do
  body = @resposta_api.parsed_response
  expected_category_slug = public_filters_data.fetch('valid_category_slug')

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |item|
    # O resumo público pode omitir category; quando vier, precisa respeitar o filtro.
    next unless item.key?('category') && item['category'].is_a?(Hash)

    expect(item['category']['slug']).to eq(expected_category_slug)
  end
end

Então('devo validar que todos os itens retornados pertencem à collection esperada quando a collection estiver presente na resposta') do
  body = @resposta_api.parsed_response
  expected_collection_slug = public_filters_data.fetch('valid_collection_slug')

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |item|
    # A API pode representar collection como objeto único ou lista de collections.
    if item.key?('collection') && item['collection'].is_a?(Hash)
      expect(item['collection']['slug']).to eq(expected_collection_slug)
    elsif item.key?('collections') && item['collections'].is_a?(Array)
      collection_slugs = item['collections'].map { |collection| collection['slug'] }
      expect(collection_slugs).to include(expected_collection_slug)
    end
  end
end

Então('devo validar que todos os itens retornados possuem a tag esperada quando tags estiverem presentes na resposta') do
  body = @resposta_api.parsed_response
  expected_tag_slug = public_filters_data.fetch('valid_tag_slug')

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |item|
    # Tags também são opcionais no resumo; validamos apenas quando o campo existe.
    next unless item.key?('tags') && item['tags'].is_a?(Array)

    tag_slugs = item['tags'].map { |tag| tag['slug'] }
    expect(tag_slugs).to include(expected_tag_slug)
  end
end

Então('devo validar que o catálogo público retornou vazio') do
  body = @resposta_api.parsed_response
  pagination = caralogo_data.fetch('public_pagination')

  # Resposta vazia ainda deve preservar metadados de paginação padrão.
  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).to be_empty
  expect(body['totalItems']).to eq(0)
  expect(body['totalPages']).to eq(0)
  expect(body['page']).to eq(pagination.fetch('valid_page'))
  expect(body['pageSize']).to eq(pagination.fetch('valid_page_size'))
end
