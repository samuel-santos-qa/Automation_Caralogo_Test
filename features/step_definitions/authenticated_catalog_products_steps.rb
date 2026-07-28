require 'time'
require 'uri'

# Lista os campos obrigatórios da resposta paginada de produtos.
def authenticated_catalog_product_list_required_fields
  %w[
    page
    pageSize
    totalItems
    totalPages
    summary
    items
  ]
end

# Lista os campos obrigatórios da resposta paginada de rankings.
def authenticated_catalog_ranking_list_required_fields
  %w[
    page
    pageSize
    totalItems
    totalPages
    summary
    items
  ]
end

# Lista os campos obrigatórios do resumo global do catálogo.
def authenticated_catalog_summary_required_fields
  %w[
    totalBrands
    totalProducts
    totalVariants
    officialProducts
    communityProducts
  ]
end

# Lista os campos obrigatórios de um produto resumido do catálogo.
def authenticated_catalog_product_required_fields
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

# Lista os campos adicionais obrigatórios do detalhe de produto.
def authenticated_catalog_product_detail_required_fields
  %w[
    sourceName
    sourceUrl
    notes
    variants
  ]
end

# Lista os campos obrigatórios de uma variante do catálogo.
def authenticated_catalog_product_variant_required_fields
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

# Lista os campos obrigatórios de uma sugestão do catálogo.
def authenticated_catalog_suggestion_required_fields
  %w[
    product
    variant
    score
    importableFields
    sourceType
    confidenceLevel
  ]
end

# Lista os campos obrigatórios de um item de ranking.
def authenticated_catalog_ranking_item_required_fields
  %w[
    product
    variant
    ranking
  ]
end

# Lista os campos obrigatórios dos metadados de ranking.
def authenticated_catalog_ranking_required_fields
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

# Confirma o formato estrutural de UUID sem limitar uma versão específica.
def authenticated_catalog_product_uuid?(value)
  value.is_a?(String) &&
    value.match?(
      /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    )
end

# Confirma o formato ISO 8601 sem expor o valor validado.
def authenticated_catalog_product_datetime?(value)
  return false unless value.is_a?(String) && !value.strip.empty?

  Time.iso8601(value)
  true
rescue ArgumentError
  false
end

# Retorna os valores de disponibilidade comercial declarados no OpenAPI.
def authenticated_catalog_product_commercial_availability_values
  %w[
    available
    legacy
    discontinued
    limited_edition
    temporarily_unavailable
    unavailable
    unknown
  ]
end

# Retorna os tipos de origem do catálogo declarados no OpenAPI.
def authenticated_catalog_product_source_type_values
  %w[
    official_site_manual_capture
    community_external_reference
    manual_user_provided
    seed_import
  ]
end

# Retorna os níveis de confiança do catálogo declarados no OpenAPI.
def authenticated_catalog_product_confidence_level_values
  %w[
    official
    curated
    community
    imported
    unverified
  ]
end

# Lista os campos obrigatórios da marca resumida de um produto.
def authenticated_catalog_product_brand_required_fields
  %w[
    id
    name
    slug
    aliases
    website
    status
    createdAt
    updatedAt
  ]
end

# Lista os campos obrigatórios do resumo de medidas do produto.
def authenticated_catalog_product_measurement_summary_required_fields
  %w[
    totalLength
    usableLength
    maxDiameter
    maxCircumference
    knotDiameter
    knotCircumference
  ]
end

# Lista os campos obrigatórios das flags resumidas do produto.
def authenticated_catalog_product_flag_required_fields
  %w[
    hasBase
    hasKnot
    hasMedialRing
    hasOneSize
    hasTopMeasurements
    hasMiddleMeasurements
    hasBottomMeasurements
  ]
end

# Lista campos administrativos que não pertencem ao resumo público do catálogo.
def authenticated_catalog_product_forbidden_fields
  %w[
    brandId
    brand_id
    sourceName
    source_name
    sourceUrl
    source_url
    notes
    archivedAt
    archived_at
    archivedByAuthProviderId
    archived_by_auth_provider_id
    archiveReason
    archive_reason
    authProviderId
    auth_provider_id
    profileId
    profile_id
    token
    tokenHash
    token_hash
    accessToken
    access_token
    refreshToken
    refresh_token
    password
    authorization
    cookie
  ]
end

# Lista campos administrativos proibidos no detalhe do produto.
def authenticated_catalog_product_detail_forbidden_fields
  authenticated_catalog_product_forbidden_fields - %w[
    sourceName
    sourceUrl
    notes
  ]
end

# Varre recursivamente apenas chaves para localizar campos administrativos proibidos.
def authenticated_catalog_product_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)

      found.concat(
        authenticated_catalog_product_forbidden_fields_found(
          value,
          forbidden_fields
        )
      )
    end
  when Array
    body.flat_map do |item|
      authenticated_catalog_product_forbidden_fields_found(
        item,
        forbidden_fields
      )
    end
  else
    []
  end.uniq
end

# Valida o contrato do resumo global do catálogo.
def validate_authenticated_catalog_summary_contract(summary, context)
  expect(summary).to be_a(Hash),
                     "#{context} deve ser um objeto"

  authenticated_catalog_summary_required_fields.each do |field|
    expect(summary).to have_key(field),
                       "Campo obrigatório ausente em #{context}: #{field}"

    expect(summary[field]).to be_a(Integer),
                              "Campo #{field} de #{context} deve ser inteiro"

    expect(summary[field]).to be >= 0,
                              "Campo #{field} de #{context} não pode ser negativo"
  end
end

# Valida o contrato comum de um produto resumido ou detalhado do catálogo.
def validate_authenticated_catalog_product_common_contract(product, context)
  expect(product).to be_a(Hash),
                     "#{context} deve ser um objeto"

  authenticated_catalog_product_required_fields.each do |field|
    expect(product).to have_key(field),
                       "Campo obrigatório ausente em #{context}: #{field}"
  end

  expect(authenticated_catalog_product_uuid?(product['id'])).to be(true),
                                                                "Campo id de #{context} deve ser um UUID válido"

  %w[slug name displayName].each do |field|
    expect(product[field]).to be_a(String),
                               "Campo #{field} de #{context} deve ser String"
    expect(product[field].strip).not_to be_empty,
                                     "Campo #{field} de #{context} não pode ser vazio"
  end

  expect(product['aliases']).to be_an(Array),
                                "Campo aliases de #{context} deve ser Array"

  product['aliases'].each_with_index do |alias_name, alias_index|
    expect(alias_name).to be_a(String),
                          "Alias #{alias_index} de #{context} deve ser String"
    expect(alias_name.strip).not_to be_empty,
                                "Alias #{alias_index} de #{context} não pode ser vazio"
  end

  unless product['category'].nil?
    expect(product['category']).to be_a(String),
                                      "Campo category de #{context} deve ser nil ou String"
    expect(product['category'].strip).not_to be_empty,
                                            "Campo category de #{context} não pode ser vazio"
  end

  expect(
    authenticated_catalog_product_commercial_availability_values
  ).to include(product['commercialAvailability']),
       "commercialAvailability inválido em #{context}"

  expect(
    authenticated_catalog_product_source_type_values
  ).to include(product['sourceType']),
       "sourceType inválido em #{context}"

  expect(
    authenticated_catalog_product_confidence_level_values
  ).to include(product['confidenceLevel']),
       "confidenceLevel inválido em #{context}"

  expect(product['variantCount']).to be_a(Integer),
                                     "Campo variantCount de #{context} deve ser inteiro"
  expect(product['variantCount']).to be >= 0,
                                     "Campo variantCount de #{context} não pode ser negativo"

  expect(product['sizes']).to be_an(Array),
                                "Campo sizes de #{context} deve ser Array"

  product['sizes'].each_with_index do |size, size_index|
    expect(size).to be_a(String),
                    "Size #{size_index} de #{context} deve ser String"
    expect(size.strip).not_to be_empty,
                          "Size #{size_index} de #{context} não pode ser vazio"
  end

  brand = product['brand']
  expect(brand).to be_a(Hash),
                   "Campo brand de #{context} deve ser um objeto"

  authenticated_catalog_product_brand_required_fields.each do |field|
    expect(brand).to have_key(field),
                         "Campo obrigatório ausente na marca de #{context}: #{field}"
  end

  expect(authenticated_catalog_product_uuid?(brand['id'])).to be(true),
                                                              "Campo id da marca de #{context} deve ser um UUID válido"

  %w[name slug status].each do |field|
    expect(brand[field]).to be_a(String),
                               "Campo #{field} da marca de #{context} deve ser String"
    expect(brand[field].strip).not_to be_empty,
                                     "Campo #{field} da marca de #{context} não pode ser vazio"
  end

  expect(brand['aliases']).to be_an(Array),
                                "Campo aliases da marca de #{context} deve ser Array"

  brand['aliases'].each_with_index do |alias_name, alias_index|
    expect(alias_name).to be_a(String),
                          "Alias #{alias_index} da marca de #{context} deve ser String"
    expect(alias_name.strip).not_to be_empty,
                                "Alias #{alias_index} da marca de #{context} não pode ser vazio"
  end

  unless brand['website'].nil?
    expect(brand['website']).to be_a(String),
                                    "Campo website da marca de #{context} deve ser nil ou String"
    expect(brand['website'].strip).not_to be_empty,
                                          "Campo website da marca de #{context} não pode ser vazio"
  end

  %w[createdAt updatedAt].each do |field|
    expect(authenticated_catalog_product_datetime?(brand[field])).to be(true),
                                                                       "Campo #{field} da marca de #{context} deve ser um date-time válido"
  end

  summary = product['summary']
  expect(summary).to be_a(Hash),
                     "Campo summary de #{context} deve ser um objeto"

  authenticated_catalog_product_measurement_summary_required_fields.each do |field|
    expect(summary).to have_key(field),
                        "Campo obrigatório ausente no summary de #{context}: #{field}"

    next if summary[field].nil?

    expect(summary[field]).to be_a(Numeric),
                              "Campo #{field} do summary de #{context} deve ser nil ou numérico"
  end

  flags = product['flags']
  expect(flags).to be_a(Hash),
                   "Campo flags de #{context} deve ser um objeto"

  authenticated_catalog_product_flag_required_fields.each do |field|
    expect(flags).to have_key(field),
                      "Campo obrigatório ausente nas flags de #{context}: #{field}"
    expect([true, false]).to include(flags[field]),
                                "Campo #{field} das flags de #{context} deve ser booleano"
  end
end

# Valida o contrato de uma variante retornada no detalhe do produto.
def validate_authenticated_catalog_product_variant_contract(
  variant,
  context,
  expected_measurement_unit: 'inch'
)
  expect(variant).to be_a(Hash),
                     "#{context} deve ser um objeto"

  authenticated_catalog_product_variant_required_fields.each do |field|
    expect(variant).to have_key(field),
                           "Campo obrigatório ausente em #{context}: #{field}"
  end

  expect(authenticated_catalog_product_uuid?(variant['id'])).to be(true),
                                                               "Campo id de #{context} deve ser um UUID válido"

  %w[sizeLabel sizeNormalized].each do |field|
    expect(variant[field]).to be_a(String),
                               "Campo #{field} de #{context} deve ser String"

    expect(variant[field].strip).not_to be_empty,
                                     "Campo #{field} de #{context} não pode ser vazio"
  end

  expect(%w[inch cm]).to include(variant['measurementUnit']),
                          "measurementUnit inválido em #{context}"

  unless expected_measurement_unit.nil?
    expect(variant['measurementUnit']).to eq(expected_measurement_unit),
                                         "#{context} deveria respeitar measurementUnit=#{expected_measurement_unit}"
  end

  expect(variant['measurements']).to be_a(Hash),
                                    "Campo measurements de #{context} deve ser um objeto"

  expect(
    authenticated_catalog_product_source_type_values
  ).to include(variant['sourceType']),
       "sourceType inválido em #{context}"

  expect(
    authenticated_catalog_product_confidence_level_values
  ).to include(variant['confidenceLevel']),
       "confidenceLevel inválido em #{context}"

  summary = variant['summary']

  expect(summary).to be_a(Hash),
                     "Campo summary de #{context} deve ser um objeto"

  authenticated_catalog_product_measurement_summary_required_fields.each do |field|
    expect(summary).to have_key(field),
                        "Campo obrigatório ausente no summary de #{context}: #{field}"

    next if summary[field].nil?

    expect(summary[field]).to be_a(Numeric),
                              "Campo #{field} do summary de #{context} deve ser nil ou numérico"
  end

  flags = variant['flags']

  expect(flags).to be_a(Hash),
                   "Campo flags de #{context} deve ser um objeto"

  authenticated_catalog_product_flag_required_fields.each do |field|
    expect(flags).to have_key(field),
                      "Campo obrigatório ausente nas flags de #{context}: #{field}"

    expect([true, false]).to include(flags[field]),
                                "Campo #{field} das flags de #{context} deve ser booleano"
  end
end

# Valida os metadados de um ranking retornado pelo catálogo.
def validate_authenticated_catalog_ranking_contract(ranking, context)
  expect(ranking).to be_a(Hash),
                     "#{context} deve ser um objeto"

  authenticated_catalog_ranking_required_fields.each do |field|
    expect(ranking).to have_key(field),
                       "Campo obrigatório ausente em #{context}: #{field}"
  end

  expect(ranking['metricKey']).to be_a(String),
                                  "Campo metricKey de #{context} deve ser String"

  expect(ranking['metricKey']).to eq('totalLength'),
                                  "#{context} deveria usar a métrica totalLength"

  expect(ranking['value']).to be_a(Numeric),
                              "Campo value de #{context} deve ser numérico quando onlyWithRankingValue=true"

  expect(
    %w[measurement diameterEquivalent]
  ).to include(ranking['valueKind']),
       "valueKind inválido em #{context}"

  unless ranking['sourceValue'].nil?
    expect(ranking['sourceValue']).to be_a(Numeric),
                                      "Campo sourceValue de #{context} deve ser nil ou numérico"
  end

  expect(%w[inch cm]).to include(ranking['unit']),
                          "Unit inválida em #{context}"

  expect(ranking['unit']).to eq('inch'),
                             "#{context} deveria respeitar measurementUnit=inch"

  unless ranking['sourceMeasurementKey'].nil?
    expect(ranking['sourceMeasurementKey']).to be_a(String),
                                               "Campo sourceMeasurementKey de #{context} deve ser nil ou String"

    expect(ranking['sourceMeasurementKey'].strip).not_to be_empty,
                                                     "Campo sourceMeasurementKey de #{context} não pode ser vazio"
  end

  unless ranking['rank'].nil?
    expect(ranking['rank']).to be_a(Integer),
                                "Campo rank de #{context} deve ser nil ou inteiro"

    expect(ranking['rank']).to be >= 1,
                                "Campo rank de #{context} deve ser positivo"
  end

  unless ranking['variantId'].nil?
    expect(
      authenticated_catalog_product_uuid?(ranking['variantId'])
    ).to be(true),
         "Campo variantId de #{context} deve ser nil ou UUID válido"
  end

  unless ranking['variantSizeLabel'].nil?
    expect(ranking['variantSizeLabel']).to be_a(String),
                                           "Campo variantSizeLabel de #{context} deve ser nil ou String"

    expect(ranking['variantSizeLabel'].strip).not_to be_empty,
                                                 "Campo variantSizeLabel de #{context} não pode ser vazio"
  end

  expect(ranking['displayLabel']).to be_a(String),
                                     "Campo displayLabel de #{context} deve ser String"

  expect(ranking['displayLabel'].strip).not_to be_empty,
                                           "Campo displayLabel de #{context} não pode ser vazio"
end

Dado('que eu tenha um produto autenticado do catálogo com variante disponível') do
  get_authenticated_endpoint('/catalog/products?page=1&pageSize=10')

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar os produtos do catálogo autenticado'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  selected_product = body['items'].find do |product|
    product['variantCount'].is_a?(Integer) &&
      product['variantCount'].positive?
  end

  expect(selected_product).not_to be_nil,
                                  'Nenhum produto com variante disponível foi encontrado na primeira página'

  expect(selected_product).to have_key('id'),
                               'O produto selecionado não possui o campo obrigatório id'

  expect(selected_product).to have_key('slug'),
                               'O produto selecionado não possui o campo obrigatório slug'

  @authenticated_catalog_product_id = selected_product['id']
  @authenticated_catalog_product_slug = selected_product['slug']
  @authenticated_catalog_product_variant_count = selected_product['variantCount']

  expect(
    authenticated_catalog_product_uuid?(@authenticated_catalog_product_id)
  ).to be(true),
       'O produto selecionado não possui um UUID válido'

  expect(@authenticated_catalog_product_slug).to be_a(String)
  expect(@authenticated_catalog_product_slug.strip).not_to be_empty
end

Dado('que eu tenha uma variante autenticada selecionada desse produto') do
  get_authenticated_endpoint(
    "/catalog/products/by-id/#{@authenticated_catalog_product_id}?measurementUnit=inch"
  )

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar o detalhe do produto autenticado'

  product = @resposta_api.parsed_response

  expect(product).to be_a(Hash)
  expect(product).to have_key('variants')
  expect(product['variants']).to be_an(Array)

  selected_variant = product['variants'].find do |variant|
    variant.is_a?(Hash) &&
      variant['id'].is_a?(String) &&
      !variant['id'].strip.empty? &&
      variant['sizeNormalized'].is_a?(String) &&
      !variant['sizeNormalized'].strip.empty?
  end

  expect(selected_variant).not_to be_nil,
                                  'Nenhuma variante válida foi encontrada no produto selecionado'

  expect(
    authenticated_catalog_product_uuid?(selected_variant['id'])
  ).to be(true),
       'A variante selecionada não possui um UUID válido'

  @authenticated_catalog_variant_id = selected_variant['id']
  @authenticated_catalog_variant_size_normalized = selected_variant['sizeNormalized']
end

Dado('que eu tenha dados conhecidos de um produto para sugestão autenticada') do
  get_authenticated_endpoint('/catalog/products?page=1&pageSize=10')

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar os produtos do catálogo autenticado'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  selected_product = body['items'].find do |product|
    product.is_a?(Hash) &&
      authenticated_catalog_product_uuid?(product['id']) &&
      product['name'].is_a?(String) &&
      !product['name'].strip.empty? &&
      product['brand'].is_a?(Hash) &&
      product['brand']['name'].is_a?(String) &&
      !product['brand']['name'].strip.empty?
  end

  expect(selected_product).not_to be_nil,
                                  'Nenhum produto válido foi encontrado para testar sugestões'

  @authenticated_catalog_suggest_product_id = selected_product['id']
  @authenticated_catalog_suggest_product_name = selected_product['name']
  @authenticated_catalog_suggest_brand_name = selected_product['brand']['name']
end

Dado('que eu tenha uma marca autenticada com vários produtos disponíveis') do
  get_authenticated_endpoint('/catalog/brands?hasProducts=true&sort=name')

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar as marcas com produtos'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  eligible_brands = body['items'].select do |brand|
    brand.is_a?(Hash) &&
      brand['slug'].is_a?(String) &&
      !brand['slug'].strip.empty? &&
      brand['productCount'].is_a?(Numeric) &&
      brand['productCount'] >= 2
  end

  selected_brand = eligible_brands.max_by do |brand|
    brand['productCount']
  end

  expect(selected_brand).not_to be_nil,
                                'Nenhuma marca com pelo menos dois produtos foi encontrada'

  @authenticated_catalog_product_brand_slug = selected_brand['slug']
end

Dado('que eu tenha uma disponibilidade comercial autenticada existente') do
  get_authenticated_endpoint('/catalog/products?page=1&pageSize=10')

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar os produtos do catálogo autenticado'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  selected_product = body['items'].find do |product|
    product.is_a?(Hash) &&
      authenticated_catalog_product_commercial_availability_values.include?(
        product['commercialAvailability']
      )
  end

  expect(selected_product).not_to be_nil,
                                  'Nenhum produto com disponibilidade comercial válida foi encontrado'

  @authenticated_catalog_commercial_availability =
    selected_product['commercialAvailability']
end

Dado('que eu tenha um nível de confiança autenticado existente') do
  get_authenticated_endpoint('/catalog/products?page=1&pageSize=10')

  expect(@resposta_api.code).to eq(200),
                                 'Não foi possível consultar os produtos do catálogo autenticado'

  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['items']).to be_an(Array)

  selected_product = body['items'].find do |product|
    product.is_a?(Hash) &&
      authenticated_catalog_product_confidence_level_values.include?(
        product['confidenceLevel']
      )
  end

  expect(selected_product).not_to be_nil,
                                  'Nenhum produto com nível de confiança válido foi encontrado'

  @authenticated_catalog_confidence_level =
    selected_product['confidenceLevel']
end

Quando('eu consultar os produtos do catálogo autenticado') do
  get_authenticated_endpoint('/catalog/products?page=1&pageSize=10')
end

Quando('eu consultar os produtos autenticados dessa marca ordenados por nome') do
  query = URI.encode_www_form(
    page: 1,
    pageSize: 10,
    brandSlug: @authenticated_catalog_product_brand_slug,
    sort: 'name',
    direction: 'asc'
  )

  get_authenticated_endpoint("/catalog/products?#{query}")
end

Quando('eu consultar os produtos autenticados dessa disponibilidade comercial') do
  query = URI.encode_www_form(
    page: 1,
    pageSize: 10,
    commercialAvailability: @authenticated_catalog_commercial_availability
  )

  get_authenticated_endpoint("/catalog/products?#{query}")
end

Quando('eu consultar os produtos autenticados desse nível de confiança') do
  query = URI.encode_www_form(
    page: 1,
    pageSize: 10,
    confidenceLevel: @authenticated_catalog_confidence_level
  )

  get_authenticated_endpoint("/catalog/products?#{query}")
end

Quando('eu consultar o detalhe desse produto autenticado por id') do
  get_authenticated_endpoint(
    "/catalog/products/by-id/#{@authenticated_catalog_product_id}?measurementUnit=inch"
  )
end

Quando('eu consultar o detalhe desse produto autenticado por slug') do
  get_authenticated_endpoint(
    "/catalog/products/#{@authenticated_catalog_product_slug}?measurementUnit=inch"
  )
end

Quando('eu consultar o detalhe dessa variante autenticada') do
  get_authenticated_endpoint(
    "/catalog/products/by-id/#{@authenticated_catalog_product_id}/variants/#{@authenticated_catalog_variant_size_normalized}?measurementUnit=inch"
  )
end

Quando('eu solicitar sugestões autenticadas para esse produto') do
  query = URI.encode_www_form(
    brand: @authenticated_catalog_suggest_brand_name,
    name: @authenticated_catalog_suggest_product_name
  )

  get_authenticated_endpoint("/catalog/suggest?#{query}")
end

Quando('eu consultar o ranking autenticado de produtos por comprimento total') do
  get_authenticated_endpoint(
    '/catalog/rankings?page=1&pageSize=10&measurementUnit=inch&rankingMetric=totalLength&rankingMode=product&rankingDirection=desc&onlyWithRankingValue=true'
  )
end

Então('devo validar a paginação da lista autenticada de produtos') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)

  authenticated_catalog_product_list_required_fields.each do |field|
    expect(body).to have_key(field),
                    "Campo obrigatório ausente na lista autenticada de produtos: #{field}"
  end

  expect(body['page']).to be_a(Integer)
  expect(body['page']).to eq(1)

  expect(body['pageSize']).to be_a(Integer)
  expect(body['pageSize']).to eq(10)

  expect(body['totalItems']).to be_a(Integer)
  expect(body['totalItems']).to be >= 0

  expect(body['totalPages']).to be_a(Integer)
  expect(body['totalPages']).to be >= 0

  expect(body['items']).to be_an(Array)
  expect(body['items'].length).to be <= body['pageSize']
end

Então('devo validar o resumo da lista autenticada de produtos') do
  summary = @resposta_api.parsed_response.fetch('summary')

  validate_authenticated_catalog_summary_contract(
    summary,
    'resumo da lista autenticada de produtos'
  )
end

Então('devo validar a paginação da lista autenticada de rankings') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)

  authenticated_catalog_ranking_list_required_fields.each do |field|
    expect(body).to have_key(field),
                    "Campo obrigatório ausente na lista autenticada de rankings: #{field}"
  end

  expect(body['page']).to be_a(Integer)
  expect(body['page']).to eq(1)

  expect(body['pageSize']).to be_a(Integer)
  expect(body['pageSize']).to eq(10)

  expect(body['totalItems']).to be_a(Integer)
  expect(body['totalItems']).to be >= 0

  expect(body['totalPages']).to be_a(Integer)
  expect(body['totalPages']).to be >= 0

  expect(body['items']).to be_an(Array)
  expect(body['items'].length).to be <= body['pageSize']
end

Então('devo validar o resumo da lista autenticada de rankings') do
  summary = @resposta_api.parsed_response.fetch('summary')

  validate_authenticated_catalog_summary_contract(
    summary,
    'resumo da lista autenticada de rankings'
  )
end

Então('a lista autenticada de rankings não deve estar vazia') do
  ranking_items = @resposta_api.parsed_response.fetch('items')

  expect(ranking_items).not_to be_empty,
                               'Nenhum resultado com valor de ranking foi retornado'
end

Então('devo validar o contrato dos rankings autenticados retornados') do
  ranking_items = @resposta_api.parsed_response.fetch('items')

  ranking_items.each_with_index do |ranking_item, index|
    expect(ranking_item).to be_a(Hash),
                             "Item de ranking #{index} deve ser um objeto"

    authenticated_catalog_ranking_item_required_fields.each do |field|
      expect(ranking_item).to have_key(field),
                               "Campo obrigatório ausente no item de ranking #{index}: #{field}"
    end

    validate_authenticated_catalog_product_common_contract(
      ranking_item['product'],
      "produto do ranking #{index}"
    )

    unless ranking_item['variant'].nil?
      validate_authenticated_catalog_product_variant_contract(
        ranking_item['variant'],
        "variante do ranking #{index}"
      )
    end

    validate_authenticated_catalog_ranking_contract(
      ranking_item['ranking'],
      "metadados do ranking #{index}"
    )
  end
end

Então('os rankings autenticados devem estar ordenados do maior para o menor') do
  ranking_items = @resposta_api.parsed_response.fetch('items')

  values = ranking_items.map do |ranking_item|
    ranking_item.fetch('ranking').fetch('value')
  end

  expect(values).to all(be_a(Numeric)),
                    'Todos os valores do ranking devem ser numéricos'

  expect(values).to eq(values.sort.reverse),
                    'Os rankings não estão ordenados do maior para o menor'
end

Então('a resposta autenticada de rankings não deve expor campos administrativos internos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_catalog_product_forbidden_fields

  found = authenticated_catalog_product_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos administrativos proibidos encontrados nos rankings: #{found.join(', ')}"
end

Então('a lista autenticada de produtos não deve estar vazia') do
  products = @resposta_api.parsed_response.fetch('items')

  expect(products).not_to be_empty,
                          'Nenhum produto foi retornado pelo catálogo autenticado'
end

Então('a lista autenticada deve possuir pelo menos dois produtos') do
  products = @resposta_api.parsed_response.fetch('items')

  expect(products.length).to be >= 2,
                             'A consulta deve retornar pelo menos dois produtos para validar a ordenação'
end

Então('devo validar o contrato dos produtos autenticados retornados') do
  products = @resposta_api.parsed_response.fetch('items')

  products.each_with_index do |product, index|
    validate_authenticated_catalog_product_common_contract(
      product,
      "produto #{index}"
    )
  end
end

Então('todos os produtos autenticados devem pertencer à marca selecionada') do
  products = @resposta_api.parsed_response.fetch('items')

  products.each_with_index do |product, index|
    expect(product).to have_key('brand'),
                           "Campo brand ausente no produto #{index}"

    expect(product['brand']).to be_a(Hash),
                                  "Campo brand do produto #{index} deve ser um objeto"

    expect(product['brand']['slug']).to eq(
      @authenticated_catalog_product_brand_slug
    ),
                                       "Produto #{index} não pertence à marca filtrada"
  end
end

Então('os produtos autenticados devem estar ordenados por nome') do
  products = @resposta_api.parsed_response.fetch('items')

  names = products.map do |product|
    product.fetch('name').downcase
  end

  expect(names).to eq(names.sort),
                   'Os produtos não estão ordenados por nome em ordem crescente'
end

Então('todos os produtos autenticados devem possuir a disponibilidade comercial selecionada') do
  products = @resposta_api.parsed_response.fetch('items')

  products.each_with_index do |product, index|
    expect(product).to have_key('commercialAvailability'),
                           "Campo commercialAvailability ausente no produto #{index}"

    expect(product['commercialAvailability']).to eq(
      @authenticated_catalog_commercial_availability
    ),
                                                "Produto #{index} não respeitou o filtro de disponibilidade comercial"
  end
end

Então('todos os produtos autenticados devem possuir o nível de confiança selecionado') do
  products = @resposta_api.parsed_response.fetch('items')

  products.each_with_index do |product, index|
    expect(product).to have_key('confidenceLevel'),
                           "Campo confidenceLevel ausente no produto #{index}"

    expect(product['confidenceLevel']).to eq(
      @authenticated_catalog_confidence_level
    ),
                                      "Produto #{index} não respeitou o filtro de nível de confiança"
  end
end

Então('o detalhe autenticado deve corresponder ao produto selecionado') do
  product = @resposta_api.parsed_response

  expect(product).to be_a(Hash)

  expect(product['id']).to eq(@authenticated_catalog_product_id),
                            'O detalhe retornou um produto diferente do selecionado'

  expect(product['slug']).to eq(@authenticated_catalog_product_slug),
                              'O slug do detalhe não corresponde ao produto selecionado'
end

Então('o detalhe autenticado por slug deve corresponder ao produto selecionado') do
  product = @resposta_api.parsed_response

  expect(product).to be_a(Hash)

  expect(product['id']).to eq(@authenticated_catalog_product_id),
                            'A consulta por slug retornou um produto diferente do selecionado'

  expect(product['slug']).to eq(@authenticated_catalog_product_slug),
                              'O slug retornado não corresponde ao produto selecionado'
end

Então('devo validar o contrato do produto autenticado detalhado') do
  product = @resposta_api.parsed_response

  validate_authenticated_catalog_product_common_contract(
    product,
    'produto detalhado'
  )

  authenticated_catalog_product_detail_required_fields.each do |field|
    expect(product).to have_key(field),
                       "Campo obrigatório ausente no produto detalhado: #{field}"
  end

  %w[sourceName sourceUrl notes].each do |field|
    next if product[field].nil?

    expect(product[field]).to be_a(String),
                               "Campo #{field} do produto detalhado deve ser nil ou String"

    expect(product[field].strip).not_to be_empty,
                                     "Campo #{field} do produto detalhado não pode ser vazio"
  end

  expect(product['variants']).to be_an(Array),
                                'Campo variants do produto detalhado deve ser Array'
end

Então('a lista de variantes do produto autenticado não deve estar vazia') do
  variants = @resposta_api.parsed_response.fetch('variants')

  expect(variants).not_to be_empty,
                          'O produto selecionado deveria possuir pelo menos uma variante'
end

Então('devo validar o contrato das variantes autenticadas retornadas') do
  variants = @resposta_api.parsed_response.fetch('variants')

  variants.each_with_index do |variant, index|
    validate_authenticated_catalog_product_variant_contract(
      variant,
      "variante #{index}"
    )
  end
end

Então('a resposta autenticada de produtos não deve expor campos administrativos internos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_catalog_product_forbidden_fields

  found = authenticated_catalog_product_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos administrativos proibidos encontrados: #{found.join(', ')}"
end

Então('a resposta autenticada de detalhe não deve expor campos administrativos internos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_catalog_product_detail_forbidden_fields

  found = authenticated_catalog_product_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos administrativos proibidos encontrados no detalhe: #{found.join(', ')}"
end

Então('o detalhe da variante autenticada deve corresponder à variante selecionada') do
  variant = @resposta_api.parsed_response

  expect(variant).to be_a(Hash)

  expect(variant['id']).to eq(@authenticated_catalog_variant_id),
                            'O endpoint retornou uma variante diferente da selecionada'

  expect(
    variant['sizeNormalized']
  ).to eq(@authenticated_catalog_variant_size_normalized),
       'O tamanho normalizado retornado não corresponde à variante selecionada'
end

Então('devo validar o contrato da variante autenticada detalhada') do
  variant = @resposta_api.parsed_response

  validate_authenticated_catalog_product_variant_contract(
    variant,
    'variante detalhada'
  )
end

Então('a resposta autenticada da variante não deve expor campos administrativos internos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_catalog_product_forbidden_fields

  found = authenticated_catalog_product_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos administrativos proibidos encontrados na variante: #{found.join(', ')}"
end

Então('devo validar o contrato da lista autenticada de sugestões') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
end

Então('a lista autenticada de sugestões não deve estar vazia') do
  suggestions = @resposta_api.parsed_response.fetch('items')

  expect(suggestions).not_to be_empty,
                              'Nenhuma sugestão foi retornada para o produto conhecido'
end

Então('devo validar o contrato das sugestões autenticadas retornadas') do
  suggestions = @resposta_api.parsed_response.fetch('items')

  suggestions.each_with_index do |suggestion, index|
    expect(suggestion).to be_a(Hash),
                           "Sugestão #{index} deve ser um objeto"

    authenticated_catalog_suggestion_required_fields.each do |field|
      expect(suggestion).to have_key(field),
                              "Campo obrigatório ausente na sugestão #{index}: #{field}"
    end

    validate_authenticated_catalog_product_common_contract(
      suggestion['product'],
      "produto da sugestão #{index}"
    )

    unless suggestion['variant'].nil?
      validate_authenticated_catalog_product_variant_contract(
        suggestion['variant'],
        "variante da sugestão #{index}",
        expected_measurement_unit: nil
      )
    end

    expect(suggestion['score']).to be_a(Numeric),
                                    "Campo score da sugestão #{index} deve ser numérico"

    expect(suggestion['importableFields']).to be_an(Array),
                                               "Campo importableFields da sugestão #{index} deve ser Array"

    suggestion['importableFields'].each_with_index do |field, field_index|
      expect(field).to be_a(String),
                           "Campo importável #{field_index} da sugestão #{index} deve ser String"

      expect(field.strip).not_to be_empty,
                                "Campo importável #{field_index} da sugestão #{index} não pode ser vazio"
    end

    expect(
      authenticated_catalog_product_source_type_values
    ).to include(suggestion['sourceType']),
         "sourceType inválido na sugestão #{index}"

    expect(
      authenticated_catalog_product_confidence_level_values
    ).to include(suggestion['confidenceLevel']),
         "confidenceLevel inválido na sugestão #{index}"
  end
end

Então('a sugestão autenticada deve incluir o produto usado na busca') do
  suggestions = @resposta_api.parsed_response.fetch('items')

  matching_suggestion = suggestions.find do |suggestion|
    suggestion.is_a?(Hash) &&
      suggestion['product'].is_a?(Hash) &&
      suggestion['product']['id'] == @authenticated_catalog_suggest_product_id
  end

  expect(matching_suggestion).not_to be_nil,
                                     'O produto conhecido utilizado na busca não apareceu nas sugestões'
end

Então('a resposta autenticada de sugestões não deve expor campos administrativos internos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_catalog_product_forbidden_fields

  found = authenticated_catalog_product_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos administrativos proibidos encontrados nas sugestões: #{found.join(', ')}"
end
