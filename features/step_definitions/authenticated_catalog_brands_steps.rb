require 'time'

# Lista os campos obrigatórios de uma marca do catálogo autenticado.
def authenticated_catalog_brand_required_fields
  %w[
    id
    name
    slug
    aliases
    website
    status
    productCount
    createdAt
    updatedAt
  ]
end

# Confirma o formato estrutural de UUID sem limitar a uma versão específica.
def authenticated_catalog_brand_uuid?(value)
  value.is_a?(String) &&
    value.match?(
      /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    )
end

# Confirma o formato ISO 8601 sem incluir o valor na mensagem de falha.
def authenticated_catalog_brand_datetime?(value)
  return false unless value.is_a?(String) && !value.strip.empty?

  Time.iso8601(value)
  true
rescue ArgumentError
  false
end

# Lista campos administrativos que não pertencem ao DTO comum do catálogo.
def authenticated_catalog_brand_forbidden_fields
  %w[
    archivedAt
    archived_at
    archivedByAuthProviderId
    archived_by_auth_provider_id
    archiveReason
    archive_reason
    totalProductCount
    total_product_count
    activeProductCount
    active_product_count
    authProviderId
    auth_provider_id
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
def authenticated_catalog_brand_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)

      found.concat(
        authenticated_catalog_brand_forbidden_fields_found(
          value,
          forbidden_fields
        )
      )
    end
  when Array
    body.flat_map do |item|
      authenticated_catalog_brand_forbidden_fields_found(
        item,
        forbidden_fields
      )
    end
  else
    []
  end.uniq
end

Quando('eu consultar as marcas do catálogo autenticado') do
  get_authenticated_endpoint('/catalog/brands')
end

Quando('eu consultar as marcas autenticadas com produtos ordenadas por nome') do
  get_authenticated_endpoint(
    '/catalog/brands?hasProducts=true&sort=name'
  )
end

Então('devo validar o contrato da lista autenticada de marcas') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
end

Então('a lista autenticada de marcas não deve estar vazia') do
  brands = @resposta_api.parsed_response.fetch('items')

  expect(brands).not_to be_empty,
                        'Nenhuma marca foi retornada pelo catálogo autenticado'
end

Então('devo validar o contrato das marcas autenticadas retornadas') do
  brands = @resposta_api.parsed_response.fetch('items')

  brands.each_with_index do |brand, index|
    expect(brand).to be_a(Hash),
                         "Marca #{index} deve ser um objeto"

    authenticated_catalog_brand_required_fields.each do |field|
      expect(brand).to have_key(field),
                           "Campo obrigatório ausente na marca #{index}: #{field}"
    end

    expect(authenticated_catalog_brand_uuid?(brand['id'])).to be(true),
                                                               "Campo id da marca #{index} deve ser um UUID válido"

    %w[name slug status].each do |field|
      expect(brand[field]).to be_a(String),
                                 "Campo #{field} da marca #{index} deve ser String"

      expect(brand[field].strip).not_to be_empty,
                                       "Campo #{field} da marca #{index} não pode ser vazio"
    end

    expect(brand['aliases']).to be_an(Array),
                                  "Campo aliases da marca #{index} deve ser Array"

    brand['aliases'].each_with_index do |alias_name, alias_index|
      expect(alias_name).to be_a(String),
                            "Alias #{alias_index} da marca #{index} deve ser String"

      expect(alias_name.strip).not_to be_empty,
                                  "Alias #{alias_index} da marca #{index} não pode ser vazio"
    end

    unless brand['website'].nil?
      expect(brand['website']).to be_a(String),
                                      "Campo website da marca #{index} deve ser nil ou String"

      expect(brand['website'].strip).not_to be_empty,
                                            "Campo website da marca #{index} não pode ser vazio"
    end

    expect(brand['productCount']).to be_a(Numeric),
                                        "Campo productCount da marca #{index} deve ser numérico"

    expect(brand['productCount']).to be >= 0,
                                       "Campo productCount da marca #{index} não pode ser negativo"

    %w[createdAt updatedAt].each do |field|
      expect(authenticated_catalog_brand_datetime?(brand[field])).to be(true),
                                                                         "Campo #{field} da marca #{index} deve ser um date-time válido"
    end
  end
end

Então('todas as marcas autenticadas retornadas devem possuir produtos') do
  brands = @resposta_api.parsed_response.fetch('items')

  brands.each_with_index do |brand, index|
    expect(brand).to have_key('productCount'),
                         "Campo productCount ausente na marca #{index}"

    expect(brand['productCount']).to be_a(Numeric),
                                      "Campo productCount da marca #{index} deve ser numérico"

    expect(brand['productCount']).to be > 0,
                                      "Marca #{index} não deveria ser retornada com hasProducts=true"
  end
end

Então('as marcas autenticadas retornadas devem estar ordenadas por nome') do
  brands = @resposta_api.parsed_response.fetch('items')

  names = brands.map do |brand|
    brand.fetch('name').downcase
  end

  expect(names).to eq(names.sort),
                   'As marcas não estão ordenadas por nome em ordem crescente'
end

Então('a resposta autenticada de marcas não deve expor campos administrativos internos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_catalog_brand_forbidden_fields

  found = authenticated_catalog_brand_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos administrativos proibidos encontrados: #{found.join(', ')}"
end
