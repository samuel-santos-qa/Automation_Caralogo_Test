# Lê a massa principal do Carálogo centralizada no YAML.
def caralogo_data
  MASSA.fetch('caralogo')
end

# Centraliza os status esperados por tipo de resposta no YAML.
def expected_status(key)
  caralogo_data.fetch('expected_status').fetch(key)
end

# Agrupa dados inválidos reutilizados em testes públicos negativos.
def invalid_public_data
  caralogo_data.fetch('invalid_public')
end

# Centraliza requisições GET públicas sem adicionar headers de autenticação.
def get_endpoint(endpoint)
  @resposta_api = CaralogoApi.get(endpoint)
end

Quando('eu fizer uma requisição GET para {string}') do |endpoint|
  get_endpoint(endpoint)
end

Então('devo receber status code {int}') do |status_code|
  expect(@resposta_api.code).to eq(status_code)
end

Então('devo receber status code de acesso não autorizado') do
  expect(expected_status('unauthorized')).to include(@resposta_api.code)
end

Então('devo receber status code de recurso indisponível') do
  expect(expected_status('unavailable')).to include(@resposta_api.code)
end

Quando('eu fizer uma requisição GET para uma rota pública inválida do tipo {string}') do |tipo_rota|
  handle = invalid_public_data.fetch('invalid_handle')
  slug = invalid_public_data.fetch('invalid_item_slug')

  # Mapa evita espalhar endpoints negativos equivalentes em vários steps.
  endpoints = {
    'perfil' => "/@#{handle}",
    'itens' => "/@#{handle}/items",
    'filtros' => "/@#{handle}/filter-options",
    'detalhe_item' => "/@#{handle}/items/#{slug}"
  }

  endpoint = endpoints.fetch(tipo_rota) do
    raise ArgumentError, "Tipo de rota pública inválida não mapeado: #{tipo_rota}"
  end

  get_endpoint(endpoint)
end

Quando('eu fizer uma requisição GET para um share token inválido') do
  # Token inválido testa formato/valor inexistente, diferente do token revogado de share.
  token = invalid_public_data.fetch('invalid_share_token')

  get_endpoint("/share/items/#{token}")
end
