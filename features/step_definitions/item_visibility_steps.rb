# Lê a massa YAML de itens que nunca devem aparecer no catálogo público.
def non_public_items_data
  caralogo_data.fetch('non_public_items')
end

# Retorna os itens da resposta atual após validar o contrato mínimo de catálogo paginado.
def current_public_items
  body = @resposta_api.parsed_response

  expect(body).to be_a(Hash)
  expect(body).to have_key('items')
  expect(body['items']).to be_an(Array)

  body['items']
end

# Retorna apenas os nomes para simplificar a validação de ausência.
def current_public_item_names
  current_public_items.map { |item| item['name'] }
end

Então('devo validar que itens private e unlisted não aparecem no resultado público') do
  item_names = current_public_item_names

  # A lista de não públicos pode crescer sem exigir novos expects no step.
  non_public_items_data.fetch('item_names').each do |non_public_item_name|
    expect(item_names).not_to include(non_public_item_name),
                               "Item não público apareceu indevidamente no catálogo público: #{non_public_item_name}"
  end
end
