# language: pt

@authenticated
Funcionalidade: Produtos do catálogo autenticado

  Cenário: Listar produtos do catálogo de referência
    Quando eu consultar os produtos do catálogo autenticado
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de produtos
    E devo validar o resumo da lista autenticada de produtos
    E a lista autenticada de produtos não deve estar vazia
    E devo validar o contrato dos produtos autenticados retornados
    E a resposta autenticada de produtos não deve expor campos administrativos internos

  Cenário: Filtrar produtos por marca e ordenar por nome
    Dado que eu tenha uma marca autenticada com vários produtos disponíveis
    Quando eu consultar os produtos autenticados dessa marca ordenados por nome
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de produtos
    E a lista autenticada de produtos não deve estar vazia
    E a lista autenticada deve possuir pelo menos dois produtos
    E devo validar o contrato dos produtos autenticados retornados
    E todos os produtos autenticados devem pertencer à marca selecionada
    E os produtos autenticados devem estar ordenados por nome
    E a resposta autenticada de produtos não deve expor campos administrativos internos

  Cenário: Filtrar produtos por disponibilidade comercial
    Dado que eu tenha uma disponibilidade comercial autenticada existente
    Quando eu consultar os produtos autenticados dessa disponibilidade comercial
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de produtos
    E a lista autenticada de produtos não deve estar vazia
    E devo validar o contrato dos produtos autenticados retornados
    E todos os produtos autenticados devem possuir a disponibilidade comercial selecionada
    E a resposta autenticada de produtos não deve expor campos administrativos internos

  Cenário: Filtrar produtos por nível de confiança
    Dado que eu tenha um nível de confiança autenticado existente
    Quando eu consultar os produtos autenticados desse nível de confiança
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de produtos
    E a lista autenticada de produtos não deve estar vazia
    E devo validar o contrato dos produtos autenticados retornados
    E todos os produtos autenticados devem possuir o nível de confiança selecionado
    E a resposta autenticada de produtos não deve expor campos administrativos internos

  Cenário: Filtrar produtos que possuem knot
    Quando eu consultar os produtos autenticados que possuem knot
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de produtos
    E a lista autenticada de produtos não deve estar vazia
    E devo validar o contrato dos produtos autenticados retornados
    E todos os produtos autenticados retornados devem possuir knot
    E a resposta autenticada de produtos não deve expor campos administrativos internos

  Cenário: Buscar produto autenticado pelo nome
    Dado que eu tenha um produto autenticado disponível para busca
    Quando eu buscar os produtos autenticados pelo nome desse produto
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de produtos
    E a lista autenticada de produtos não deve estar vazia
    E devo validar o contrato dos produtos autenticados retornados
    E o produto autenticado selecionado deve aparecer no resultado da busca
    E a resposta autenticada de produtos não deve expor campos administrativos internos

  Cenário: Navegar para a segunda página de produtos autenticados
    Dado que eu tenha a primeira página autenticada de produtos para comparação
    Quando eu consultar a segunda página autenticada de produtos
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de produtos
    E a lista autenticada de produtos não deve estar vazia
    E devo validar o contrato dos produtos autenticados retornados
    E os totais da paginação autenticada devem permanecer consistentes
    E os produtos da segunda página não devem repetir os da primeira página
    E a resposta autenticada de produtos não deve expor campos administrativos internos
