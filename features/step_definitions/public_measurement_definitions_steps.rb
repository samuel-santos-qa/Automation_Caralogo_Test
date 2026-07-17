# Retorna os campos mínimos exigidos pelo contrato de uma measurement definition pública.
def public_measurement_definition_required_fields
  %w[
    id
    slug
    labelPt
    labelEn
    unitFamily
    baseUnit
    valueKind
    isStandard
    isFilterable
    displayGroup
    sortOrder
  ]
end

# Lê da massa existente o slug usado pelos filtros públicos de measurements.
def expected_public_measurement_definition_slug
  caralogo_data.fetch('public_measurement_filters').fetch('valid_measurement_slug')
end

# Faz GET com Authorization inválido apenas para validar o comportamento viewer-aware.
def get_public_measurement_definitions_with_invalid_auth(endpoint)
  @resposta_api = CaralogoApi.get(
    endpoint,
    request_options_with_headers('Authorization' => 'Bearer invalid-token-qa')
  )
end

Quando('eu fizer uma requisição GET para as measurement definitions públicas do perfil') do
  get_endpoint("/@#{@public_handle}/measurement-definitions")
end

Quando('eu fizer uma requisição GET para measurement definitions de um handle público inexistente') do
  invalid_handle = invalid_public_data.fetch('invalid_handle')

  get_endpoint("/@#{invalid_handle}/measurement-definitions")
end

Quando('eu fizer uma requisição GET para measurement definitions públicas com Authorization inválido') do
  endpoint = "/@#{@public_handle}/measurement-definitions"

  get_public_measurement_definitions_with_invalid_auth(endpoint)
end

Então('devo validar o contrato das measurement definitions públicas') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
  expect(body['items']).not_to be_empty

  body['items'].each do |definition|
    expect(definition).to be_a(Hash)

    public_measurement_definition_required_fields.each do |field|
      expect(definition).to have_key(field), "Campo obrigatório ausente na measurement definition pública: #{field}"
    end
  end
end

Então('devo validar que existe uma definition esperada') do
  body = @resposta_api.parsed_response
  expected_slug = expected_public_measurement_definition_slug
  definition = body.fetch('items').find { |item| item['slug'] == expected_slug }

  expect(definition).not_to be_nil, "Measurement definition pública não encontrada: #{expected_slug}"
end
