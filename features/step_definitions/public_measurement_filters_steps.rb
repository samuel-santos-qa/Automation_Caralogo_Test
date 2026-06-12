require 'uri'

def public_measurement_filters_data
  caralogo_data.fetch('public_measurement_filters')
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurement em centímetros') do
  measurement_data = public_measurement_filters_data

  query = URI.encode_www_form(
    measurementSlug: measurement_data.fetch('valid_measurement_slug'),
    measurementUnit: measurement_data.fetch('valid_unit_cm'),
    measurementMin: measurement_data.fetch('valid_min_cm'),
    measurementMax: measurement_data.fetch('valid_max_cm')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurement em milímetros') do
  measurement_data = public_measurement_filters_data

  query = URI.encode_www_form(
    measurementSlug: measurement_data.fetch('valid_measurement_slug'),
    measurementUnit: measurement_data.fetch('valid_unit_mm'),
    measurementMin: measurement_data.fetch('valid_min_mm'),
    measurementMax: measurement_data.fetch('valid_max_mm')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end

Quando('eu fizer uma requisição GET para a lista pública de itens filtrando por measurement fora do intervalo') do
  measurement_data = public_measurement_filters_data

  query = URI.encode_www_form(
    measurementSlug: measurement_data.fetch('valid_measurement_slug'),
    measurementUnit: measurement_data.fetch('out_of_range_unit'),
    measurementMin: measurement_data.fetch('out_of_range_min'),
    measurementMax: measurement_data.fetch('out_of_range_max')
  )

  get_endpoint("/@#{@public_handle}/items?#{query}")
end
