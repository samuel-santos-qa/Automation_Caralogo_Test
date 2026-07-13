require 'uri'

# Lista os campos mínimos exigidos para uma marca pública do catálogo de referência.
def public_catalog_brand_required_fields
  %w[id name slug aliases website status productCount createdAt updatedAt]
end

# Lista os campos mínimos exigidos para um produto público do catálogo de referência.
def public_catalog_product_required_fields
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
  ]
end

# Lista os campos mínimos exigidos para a marca resumida dentro de um produto.
def public_catalog_brand_summary_required_fields
  %w[id name slug]
end

# Lista os campos mínimos exigidos para uma sugestão pública do catálogo.
def public_catalog_suggestion_required_fields
  %w[product variant score importableFields sourceType confidenceLevel]
end

# Monta query string com encoding seguro para buscas e filtros do Public Catalog.
def public_catalog_query(params)
  URI.encode_www_form(params)
end

# Extrai itens de uma resposta de descoberta após validar status e contrato mínimo.
def public_catalog_discovery_items(response, resource_name)
  expect(response.code).to eq(200), "Falha ao descobrir #{resource_name} no Public Catalog"

  body = response.parsed_response
  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty, "Nenhum #{resource_name} disponível para o cenário dinâmico"

  body['items']
end

# Descobre a primeira marca pública disponível sem depender de massa fixa.
def first_public_catalog_brand
  response = CaralogoApi.get('/public/catalog/brands')

  public_catalog_discovery_items(response, 'marca pública').first
end

# Descobre o primeiro produto público disponível sem depender de massa fixa.
def first_public_catalog_product
  response = CaralogoApi.get('/public/catalog/products')

  public_catalog_discovery_items(response, 'produto público').first
end

# Escolhe a parte mais significativa do nome da marca para a busca dinâmica.
def public_catalog_brand_search_term(brand)
  brand.fetch('name').split.max_by(&:length)
end

Dado('que eu tenha uma marca pública do catálogo de referência') do
  @public_catalog_brand = first_public_catalog_brand
end

Dado('que eu tenha um produto público do catálogo de referência') do
  @public_catalog_product = first_public_catalog_product
end

Quando('eu fizer uma requisição GET para as marcas públicas do catálogo') do
  get_endpoint('/public/catalog/brands')
end

Quando('eu buscar marcas públicas do catálogo usando parte do nome dessa marca') do
  search_term = public_catalog_brand_search_term(@public_catalog_brand)
  query = public_catalog_query(search: search_term)
  @expected_public_catalog_brand_slug = @public_catalog_brand.fetch('slug')

  get_endpoint("/public/catalog/brands?#{query}")
end

Quando('eu fizer uma requisição GET para os produtos públicos do catálogo') do
  get_endpoint('/public/catalog/products')
end

Quando('eu filtrar produtos públicos do catálogo pelo brandSlug desse produto') do
  @expected_public_catalog_brand_slug = @public_catalog_product.dig('brand', 'slug')
  expect(@expected_public_catalog_brand_slug).not_to be_nil, 'Produto descoberto não possui brand.slug'

  query = public_catalog_query(brandSlug: @expected_public_catalog_brand_slug)
  get_endpoint("/public/catalog/products?#{query}")
end

Quando('eu pedir sugestões públicas do catálogo usando o nome desse produto') do
  @expected_public_catalog_product_id = @public_catalog_product.fetch('id')
  query = public_catalog_query(search: @public_catalog_product.fetch('name'))

  get_endpoint("/public/catalog/suggest?#{query}")
end

Então('devo validar o contrato da lista pública de marcas do catálogo') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |brand|
    expect(brand).to be_a(Hash)

    public_catalog_brand_required_fields.each do |field|
      expect(brand).to have_key(field), "Campo obrigatório ausente na marca pública: #{field}"
    end
  end
end

Então('devo validar que a busca retorna a marca esperada') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty, 'A busca pública de marcas retornou vazia'

  returned_slugs = body['items'].map { |brand| brand['slug'] }
  expect(returned_slugs).to include(@expected_public_catalog_brand_slug)
end

Então('devo validar o contrato da lista pública de produtos do catálogo') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  %w[page pageSize totalItems totalPages summary items].each do |field|
    expect(body).to have_key(field), "Campo obrigatório ausente na lista pública de produtos: #{field}"
  end

  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |product|
    expect(product).to be_a(Hash)

    public_catalog_product_required_fields.each do |field|
      expect(product).to have_key(field), "Campo obrigatório ausente no produto público: #{field}"
    end

    expect(product['brand']).to be_a(Hash)
    public_catalog_brand_summary_required_fields.each do |field|
      expect(product['brand']).to have_key(field), "Campo obrigatório ausente na marca do produto: #{field}"
    end
  end
end

Então('devo validar que os produtos retornados pertencem à marca esperada') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty, 'O filtro público por brandSlug retornou vazio'

  body['items'].each do |product|
    expect(product.dig('brand', 'slug')).to eq(@expected_public_catalog_brand_slug)
  end
end

Então('devo validar o contrato das sugestões públicas do catálogo') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |suggestion|
    expect(suggestion).to be_a(Hash)

    public_catalog_suggestion_required_fields.each do |field|
      expect(suggestion).to have_key(field), "Campo obrigatório ausente na sugestão pública: #{field}"
    end

    expect(suggestion['product']).to be_a(Hash)
  end
end

Então('devo validar que a sugestão retorna o produto esperado') do
  body = @resposta_api.parsed_response
  returned_product_ids = body.fetch('items').map { |suggestion| suggestion.dig('product', 'id') }

  expect(returned_product_ids).to include(@expected_public_catalog_product_id)
end
