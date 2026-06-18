require 'uri'

# Lê a massa YAML dos filtros públicos por measurements.
def public_measurement_filters_data
  caralogo_data.fetch('public_measurement_filters')
end

# Monta query string com encoding seguro para filtros de measurements.
def public_measurement_query(measurement_slug:, measurement_unit:, measurement_min:, measurement_max:)
  URI.encode_www_form(
    measurementSlug: measurement_slug,
    measurementUnit: measurement_unit,
    measurementMin: measurement_min,
    measurementMax: measurement_max
  )
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurement em centímetros') do
  measurement_data = public_measurement_filters_data

  query = public_measurement_query(
    measurement_slug: measurement_data.fetch('valid_measurement_slug'),
    measurement_unit: measurement_data.fetch('valid_unit_cm'),
    measurement_min: measurement_data.fetch('valid_min_cm'),
    measurement_max: measurement_data.fetch('valid_max_cm')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurement em milímetros') do
  measurement_data = public_measurement_filters_data

  query = public_measurement_query(
    measurement_slug: measurement_data.fetch('valid_measurement_slug'),
    measurement_unit: measurement_data.fetch('valid_unit_mm'),
    measurement_min: measurement_data.fetch('valid_min_mm'),
    measurement_max: measurement_data.fetch('valid_max_mm')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurement fora do intervalo') do
  measurement_data = public_measurement_filters_data

  query = public_measurement_query(
    measurement_slug: measurement_data.fetch('valid_measurement_slug'),
    measurement_unit: measurement_data.fetch('out_of_range_unit'),
    measurement_min: measurement_data.fetch('out_of_range_min'),
    measurement_max: measurement_data.fetch('out_of_range_max')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurementSlug inexistente') do
  measurement_data = public_measurement_filters_data

  query = public_measurement_query(
    measurement_slug: measurement_data.fetch('invalid_measurement_slug'),
    measurement_unit: measurement_data.fetch('valid_unit_cm'),
    measurement_min: measurement_data.fetch('valid_min_cm'),
    measurement_max: measurement_data.fetch('valid_max_cm')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurementUnit inválida') do
  measurement_data = public_measurement_filters_data

  query = public_measurement_query(
    measurement_slug: measurement_data.fetch('valid_measurement_slug'),
    measurement_unit: measurement_data.fetch('invalid_unit'),
    measurement_min: measurement_data.fetch('valid_min_cm'),
    measurement_max: measurement_data.fetch('valid_max_cm')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurementMin inválido') do
  measurement_data = public_measurement_filters_data

  query = public_measurement_query(
    measurement_slug: measurement_data.fetch('valid_measurement_slug'),
    measurement_unit: measurement_data.fetch('valid_unit_cm'),
    measurement_min: measurement_data.fetch('invalid_min'),
    measurement_max: measurement_data.fetch('valid_max_cm')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurementMax inválido') do
  measurement_data = public_measurement_filters_data

  query = public_measurement_query(
    measurement_slug: measurement_data.fetch('valid_measurement_slug'),
    measurement_unit: measurement_data.fetch('valid_unit_cm'),
    measurement_min: measurement_data.fetch('valid_min_cm'),
    measurement_max: measurement_data.fetch('invalid_max')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Então('devo validar a mensagem de erro para measurementUnit inválida') do
  body = @resposta_api.parsed_response
  expected_message = public_measurement_filters_data.fetch('expected_invalid_unit_message')

  # Valida trecho da mensagem para evitar acoplamento ao texto completo do backend.
  expect(body).to be_a(Hash)
  expect(body['statusCode']).to eq(400)
  expect(body['error']).to eq('Bad Request')
  expect(body['message']).to be_an(Array)
  expect(body['message'].join(' ')).to include(expected_message)
end
