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
