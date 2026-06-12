Então('a resposta deve conter o campo {string} com o valor {string}') do |campo, valor|
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key(campo)
  expect(body[campo]).to eq(valor)
end
