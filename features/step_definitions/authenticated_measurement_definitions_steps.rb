# Lista os campos obrigatórios de uma definição de measurement autenticada.
def authenticated_measurement_definition_required_fields
  %w[
    id
    slug
    labelPt
    labelEn
    description
    unitFamily
    baseUnit
    valueKind
    thicknessScope
    isStandard
    isFilterable
    displayGroup
    sortOrder
  ]
end

# Lista campos técnicos que não devem aparecer nas definições owner-safe.
def authenticated_measurement_definition_forbidden_fields
  %w[
    profileId
    profile_id
    authProviderId
    auth_provider_id
    tokenHash
    token_hash
    accessToken
    access_token
    refreshToken
    refresh_token
    password
    authorization
    cookie
    deletedAt
    deleted_at
  ]
end

# Varre recursivamente apenas chaves para localizar campos internos proibidos.
def authenticated_measurement_definition_forbidden_fields_found(body, forbidden_fields)
  case body
  when Hash
    body.each_with_object([]) do |(key, value), found|
      found << key if forbidden_fields.include?(key)

      found.concat(
        authenticated_measurement_definition_forbidden_fields_found(
          value,
          forbidden_fields
        )
      )
    end
  when Array
    body.flat_map do |item|
      authenticated_measurement_definition_forbidden_fields_found(
        item,
        forbidden_fields
      )
    end
  else
    []
  end.uniq
end

Quando('eu consultar as definições de measurements autenticadas') do
  get_authenticated_endpoint('/me/measurement-definitions')
end

Então('devo validar o contrato da lista de definições autenticadas') do
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)
end

Então('a lista de definições autenticadas não deve estar vazia') do
  definitions = @resposta_api.parsed_response.fetch('items')

  expect(definitions).not_to be_empty,
                             'Nenhuma definição de measurement foi retornada para o proprietário'
end

Então('devo validar o contrato das definições autenticadas retornadas') do
  definitions = @resposta_api.parsed_response.fetch('items')

  definitions.each_with_index do |definition, index|
    expect(definition).to be_a(Hash),
                              "Definição #{index} deve ser um objeto"

    authenticated_measurement_definition_required_fields.each do |field|
      expect(definition).to have_key(field),
                                 "Campo obrigatório ausente na definição #{index}: #{field}"
    end

    %w[id slug labelPt labelEn displayGroup].each do |field|
      expect(definition[field]).to be_a(String),
                                      "Campo #{field} da definição #{index} deve ser String"

      expect(definition[field].strip).not_to be_empty,
                                            "Campo #{field} da definição #{index} não pode ser vazio"
    end

    expect(
      %w[length weight volume number percentage]
    ).to include(definition['unitFamily'])

    expect(
      %w[mm g ml number percentage]
    ).to include(definition['baseUnit'])

    expect(
      %w[length diameter circumference weight volume number percentage]
    ).to include(definition['valueKind'])

    expect(
      %w[none insertable overall base]
    ).to include(definition['thicknessScope'])

    expect([true, false]).to include(definition['isStandard'])
    expect([true, false]).to include(definition['isFilterable'])

    expect(definition['sortOrder']).to be_a(Numeric)

    %w[createdAt updatedAt].each do |field|
      next unless definition.key?(field)

      expect(definition[field]).to be_a(String),
                                      "Campo #{field} da definição #{index} deve ser String"

      expect(definition[field].strip).not_to be_empty,
                                            "Campo #{field} da definição #{index} não pode ser vazio"
    end
  end
end

Então('devo validar que existe uma definição padrão autenticada') do
  definitions = @resposta_api.parsed_response.fetch('items')

  standard_definition = definitions.find do |definition|
    definition['isStandard'] == true
  end

  expect(standard_definition).not_to be_nil,
                                      'Nenhuma definição padrão foi retornada'
end

Então('a resposta autenticada de definições não deve expor campos internos proibidos') do
  body = @resposta_api.parsed_response
  forbidden_fields = authenticated_measurement_definition_forbidden_fields

  found = authenticated_measurement_definition_forbidden_fields_found(
    body,
    forbidden_fields
  )

  expect(found).to be_empty,
                   "Campos internos proibidos encontrados nas definições: #{found.join(', ')}"
end
