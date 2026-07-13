require 'uri'

# Lista os campos obrigatórios da resposta paginada de rankings públicos.
def advanced_public_catalog_ranking_list_required_fields
  %w[page pageSize totalItems totalPages summary items]
end

# Lista os campos obrigatórios de cada item retornado nos rankings públicos.
def advanced_public_catalog_ranking_item_required_fields
  %w[product variant ranking]
end

# Lista os campos obrigatórios do objeto de ranking público.
def advanced_public_catalog_ranking_required_fields
  %w[
    metricKey
    value
    valueKind
    sourceValue
    unit
    sourceMeasurementKey
    rank
    variantId
    variantSizeLabel
    displayLabel
  ]
end

# Lista os campos obrigatórios do detalhe público de produto.
def advanced_public_catalog_product_detail_required_fields
  %w[
    id
    slug
    name
    displayName
    brand
    aliases
    category
    commercialAvailability
    sourceType
    confidenceLevel
    variantCount
    sizes
    summary
    flags
    sourceName
    sourceUrl
    notes
    variants
  ]
end

# Lista os campos obrigatórios do detalhe público de variante.
def advanced_public_catalog_variant_detail_required_fields
  %w[
    id
    sizeLabel
    sizeNormalized
    measurementUnit
    measurements
    summary
    flags
    sourceType
    confidenceLevel
  ]
end

# Monta query string com encoding seguro para filtros avançados do Public Catalog.
def advanced_public_catalog_query(params)
  URI.encode_www_form(params)
end

# Descobre os produtos públicos disponíveis e valida o contrato mínimo da resposta.
def advanced_public_catalog_products
  response = CaralogoApi.get('/public/catalog/products')
  expect(response.code).to eq(200), 'Falha ao descobrir produtos para o Public Catalog avançado'

  body = response.parsed_response
  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty, 'Nenhum produto público disponível para o cenário dinâmico'

  body['items']
end

# Descobre o primeiro produto público que informa ao menos uma size de variante.
def advanced_public_catalog_first_product_with_size
  product = advanced_public_catalog_products.find do |item|
    item['sizes'].is_a?(Array) && !item['sizes'].empty?
  end

  expect(product).not_to be_nil, 'Nenhum produto público com size de variante foi encontrado'
  product
end

Dado('que eu tenha um produto público do catálogo de referência com variante') do
  @public_catalog_product_with_variant = advanced_public_catalog_first_product_with_size
  @expected_public_catalog_variant_size = @public_catalog_product_with_variant.fetch('sizes').first
end

Quando('eu fizer uma requisição GET para os rankings públicos do catálogo') do
  get_endpoint('/public/catalog/rankings')
end

Quando('eu fizer uma requisição GET para rankings públicos usando a métrica totalLength') do
  @expected_public_catalog_ranking_metric = 'totalLength'
  query = advanced_public_catalog_query(rankingMetric: @expected_public_catalog_ranking_metric)

  get_endpoint("/public/catalog/rankings?#{query}")
end

Quando('eu fizer uma requisição GET para o detalhe público desse produto por ID') do
  @expected_public_catalog_product = {
    'id' => @public_catalog_product.fetch('id'),
    'slug' => @public_catalog_product.fetch('slug'),
    'name' => @public_catalog_product.fetch('name')
  }

  get_endpoint("/public/catalog/products/by-id/#{@expected_public_catalog_product.fetch('id')}")
end

Quando('eu fizer uma requisição GET para detalhe público de produto com ID inexistente') do
  missing_product_id = '00000000-0000-4000-8000-000000000999'

  get_endpoint("/public/catalog/products/by-id/#{missing_product_id}")
end

Quando('eu fizer uma requisição GET para o detalhe público da variante desse produto') do
  product_id = @public_catalog_product_with_variant.fetch('id')
  size = URI.encode_www_form_component(@expected_public_catalog_variant_size)

  get_endpoint("/public/catalog/products/by-id/#{product_id}/variants/#{size}")
end

Quando('eu fizer uma requisição GET para uma variante pública inexistente desse produto') do
  product_id = @public_catalog_product.fetch('id')

  get_endpoint("/public/catalog/products/by-id/#{product_id}/variants/size-inexistente-qa")
end

Então('devo validar o contrato da lista pública de rankings do catálogo') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  advanced_public_catalog_ranking_list_required_fields.each do |field|
    expect(body).to have_key(field), "Campo obrigatório ausente na lista pública de rankings: #{field}"
  end

  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |item|
    expect(item).to be_a(Hash)
    advanced_public_catalog_ranking_item_required_fields.each do |field|
      expect(item).to have_key(field), "Campo obrigatório ausente no item de ranking: #{field}"
    end

    expect(item['product']).to be_a(Hash)
    expect(item['ranking']).to be_a(Hash)
    advanced_public_catalog_ranking_required_fields.each do |field|
      expect(item['ranking']).to have_key(field), "Campo obrigatório ausente no ranking público: #{field}"
    end
  end
end

Então('devo validar que os rankings retornados usam a métrica esperada') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty, 'A consulta pública de rankings por métrica retornou vazia'

  body['items'].each do |item|
    expect(item.dig('ranking', 'metricKey')).to eq(@expected_public_catalog_ranking_metric)
  end
end

Então('devo validar o contrato do detalhe público de produto do catálogo') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  advanced_public_catalog_product_detail_required_fields.each do |field|
    expect(body).to have_key(field), "Campo obrigatório ausente no detalhe público de produto: #{field}"
  end

  expect(body['brand']).to be_a(Hash)
  expect(body['variants']).to be_an(Array)
end

Então('devo validar que o detalhe retornado pertence ao produto esperado') do
  body = @resposta_api.parsed_response

  expect(body['id']).to eq(@expected_public_catalog_product.fetch('id'))
  expect(body['slug']).to eq(@expected_public_catalog_product.fetch('slug'))
  expect(body['name']).to eq(@expected_public_catalog_product.fetch('name'))
end

Então('devo validar o contrato do detalhe público de variante do catálogo') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  advanced_public_catalog_variant_detail_required_fields.each do |field|
    expect(body).to have_key(field), "Campo obrigatório ausente no detalhe público de variante: #{field}"
  end
end

Então('devo validar que a variante retornada pertence à size esperada') do
  body = @resposta_api.parsed_response

  expect(body['sizeNormalized']).to eq(@expected_public_catalog_variant_size)
end
