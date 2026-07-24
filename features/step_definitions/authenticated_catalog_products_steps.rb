require 'time'

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

Quando('eu consultar os produtos do catálogo autenticado') do
  get_authenticated_endpoint('/catalog/products?page=1&pageSize=10')
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

  expect(summary).to be_a(Hash)

  authenticated_catalog_summary_required_fields.each do |field|
    expect(summary).to have_key(field),
                        "Campo obrigatório ausente no resumo do catálogo: #{field}"

    expect(summary[field]).to be_a(Integer),
                              "Campo #{field} do resumo deve ser inteiro"

    expect(summary[field]).to be >= 0,
                              "Campo #{field} do resumo não pode ser negativo"
  end
end

Então('a lista autenticada de produtos não deve estar vazia') do
  products = @resposta_api.parsed_response.fetch('items')

  expect(products).not_to be_empty,
                          'Nenhum produto foi retornado pelo catálogo autenticado'
end

Então('devo validar o contrato dos produtos autenticados retornados') do
  products = @resposta_api.parsed_response.fetch('items')

  products.each_with_index do |product, index|
    expect(product).to be_a(Hash),
                           "Produto #{index} deve ser um objeto"

    authenticated_catalog_product_required_fields.each do |field|
      expect(product).to have_key(field),
                             "Campo obrigatório ausente no produto #{index}: #{field}"
    end

    expect(authenticated_catalog_product_uuid?(product['id'])).to be(true),
                                                                  "Campo id do produto #{index} deve ser um UUID válido"

    %w[slug name displayName].each do |field|
      expect(product[field]).to be_a(String),
                                   "Campo #{field} do produto #{index} deve ser String"
      expect(product[field].strip).not_to be_empty,
                                         "Campo #{field} do produto #{index} não pode ser vazio"
    end

    expect(product['aliases']).to be_an(Array),
                                    "Campo aliases do produto #{index} deve ser Array"

    product['aliases'].each_with_index do |alias_name, alias_index|
      expect(alias_name).to be_a(String),
                            "Alias #{alias_index} do produto #{index} deve ser String"
      expect(alias_name.strip).not_to be_empty,
                                  "Alias #{alias_index} do produto #{index} não pode ser vazio"
    end

    unless product['category'].nil?
      expect(product['category']).to be_a(String),
                                        "Campo category do produto #{index} deve ser nil ou String"
      expect(product['category'].strip).not_to be_empty,
                                              "Campo category do produto #{index} não pode ser vazio"
    end

    expect(
      authenticated_catalog_product_commercial_availability_values
    ).to include(product['commercialAvailability']),
         "commercialAvailability inválido no produto #{index}"

    expect(
      authenticated_catalog_product_source_type_values
    ).to include(product['sourceType']),
         "sourceType inválido no produto #{index}"

    expect(
      authenticated_catalog_product_confidence_level_values
    ).to include(product['confidenceLevel']),
         "confidenceLevel inválido no produto #{index}"

    expect(product['variantCount']).to be_a(Integer),
                                       "Campo variantCount do produto #{index} deve ser inteiro"
    expect(product['variantCount']).to be >= 0,
                                       "Campo variantCount do produto #{index} não pode ser negativo"

    expect(product['sizes']).to be_an(Array),
                                  "Campo sizes do produto #{index} deve ser Array"

    product['sizes'].each_with_index do |size, size_index|
      expect(size).to be_a(String),
                      "Size #{size_index} do produto #{index} deve ser String"
      expect(size.strip).not_to be_empty,
                            "Size #{size_index} do produto #{index} não pode ser vazio"
    end

    brand = product['brand']
    expect(brand).to be_a(Hash),
                     "Campo brand do produto #{index} deve ser um objeto"

    authenticated_catalog_product_brand_required_fields.each do |field|
      expect(brand).to have_key(field),
                           "Campo obrigatório ausente na marca do produto #{index}: #{field}"
    end

    expect(authenticated_catalog_product_uuid?(brand['id'])).to be(true),
                                                                "Campo id da marca do produto #{index} deve ser um UUID válido"

    %w[name slug status].each do |field|
      expect(brand[field]).to be_a(String),
                                 "Campo #{field} da marca do produto #{index} deve ser String"
      expect(brand[field].strip).not_to be_empty,
                                       "Campo #{field} da marca do produto #{index} não pode ser vazio"
    end

    expect(brand['aliases']).to be_an(Array),
                                  "Campo aliases da marca do produto #{index} deve ser Array"

    brand['aliases'].each_with_index do |alias_name, alias_index|
      expect(alias_name).to be_a(String),
                            "Alias #{alias_index} da marca do produto #{index} deve ser String"
      expect(alias_name.strip).not_to be_empty,
                                  "Alias #{alias_index} da marca do produto #{index} não pode ser vazio"
    end

    unless brand['website'].nil?
      expect(brand['website']).to be_a(String),
                                      "Campo website da marca do produto #{index} deve ser nil ou String"
      expect(brand['website'].strip).not_to be_empty,
                                            "Campo website da marca do produto #{index} não pode ser vazio"
    end

    %w[createdAt updatedAt].each do |field|
      expect(authenticated_catalog_product_datetime?(brand[field])).to be(true),
                                                                         "Campo #{field} da marca do produto #{index} deve ser um date-time válido"
    end

    summary = product['summary']
    expect(summary).to be_a(Hash),
                       "Campo summary do produto #{index} deve ser um objeto"

    authenticated_catalog_product_measurement_summary_required_fields.each do |field|
      expect(summary).to have_key(field),
                          "Campo obrigatório ausente no summary do produto #{index}: #{field}"

      next if summary[field].nil?

      expect(summary[field]).to be_a(Numeric),
                                "Campo #{field} do summary do produto #{index} deve ser nil ou numérico"
    end

    flags = product['flags']
    expect(flags).to be_a(Hash),
                     "Campo flags do produto #{index} deve ser um objeto"

    authenticated_catalog_product_flag_required_fields.each do |field|
      expect(flags).to have_key(field),
                        "Campo obrigatório ausente nas flags do produto #{index}: #{field}"
      expect([true, false]).to include(flags[field]),
                                  "Campo #{field} das flags do produto #{index} deve ser booleano"
    end
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
