def share_media_negative_data
  caralogo_data.fetch('share_media_negative')
end

Quando('eu fizer uma requisição GET para uma imagem via share com sortOrder inexistente') do
  media_data = share_media_negative_data

  get_endpoint("/share/items/#{@share_item_token}/images/#{media_data.fetch('invalid_sort_order')}")
end

Quando('eu fizer uma requisição GET para uma imagem via share com sortOrder inválido textual') do
  media_data = share_media_negative_data

  get_endpoint("/share/items/#{@share_item_token}/images/#{media_data.fetch('invalid_sort_order_text')}")
end

Quando('eu fizer uma requisição GET para a imagem cover via share com token revogado') do
  get_endpoint("/share/items/#{@share_item_token}/images/cover")
end

Quando('eu fizer uma requisição GET para a imagem por sortOrder via share com token revogado') do
  get_endpoint("/share/items/#{@share_item_token}/images/0")
end

Então('devo validar resposta genérica de mídia via share inexistente') do
  media_data = share_media_negative_data
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body['message']).to eq(media_data.fetch('expected_message'))
  expect(body['statusCode']).to eq(media_data.fetch('expected_status_code'))
end
