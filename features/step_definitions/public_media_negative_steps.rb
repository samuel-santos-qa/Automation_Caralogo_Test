def public_media_negative_data
  caralogo_data.fetch('public_media_negative')
end

Quando('eu fizer uma requisição GET para uma imagem pública com sortOrder inexistente') do
  media_data = public_media_negative_data

  get_endpoint("/@#{@public_handle}/items/#{@public_item.fetch('slug_with_public_id')}/images/#{media_data.fetch('invalid_sort_order')}")
end

Quando('eu fizer uma requisição GET para uma imagem pública com sortOrder inválido textual') do
  media_data = public_media_negative_data

  get_endpoint("/@#{@public_handle}/items/#{@public_item.fetch('slug_with_public_id')}/images/#{media_data.fetch('invalid_sort_order_text')}")
end

Quando('eu fizer uma requisição GET para a imagem de capa de um item público inexistente') do
  invalid_data = invalid_public_data

  get_endpoint("/@#{public_profile_data.fetch('handle')}/items/#{invalid_data.fetch('invalid_item_slug')}/images/cover")
end

Quando('eu fizer uma requisição GET para a imagem por sortOrder de um item público inexistente') do
  invalid_data = invalid_public_data

  get_endpoint("/@#{public_profile_data.fetch('handle')}/items/#{invalid_data.fetch('invalid_item_slug')}/images/0")
end

Então('devo validar resposta genérica de mídia pública inexistente') do
  media_data = public_media_negative_data
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['message']).to eq(media_data.fetch('expected_message'))
  expect(body['statusCode']).to eq(media_data.fetch('expected_status_code'))
end
