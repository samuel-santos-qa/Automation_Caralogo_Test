Quando('eu fizer uma requisição GET para a imagem pública de capa') do
  handle = public_profile_data.fetch('handle')
  slug_with_public_id = public_item_data.fetch('slug_with_public_id')

  get_endpoint("/@#{handle}/items/#{slug_with_public_id}/images/cover")
end

Quando('eu fizer uma requisição GET para a imagem pública de ordem {int}') do |sort_order|
  handle = public_profile_data.fetch('handle')
  slug_with_public_id = public_item_data.fetch('slug_with_public_id')

  get_endpoint("/@#{handle}/items/#{slug_with_public_id}/images/#{sort_order}")
end

Então('a resposta deve ser uma imagem') do
  content_type = @resposta_api.headers['content-type']

  expect(content_type).not_to be_nil
  expect(content_type).to match(%r{\Aimage/})
  expect(@resposta_api.body).not_to be_empty
end
