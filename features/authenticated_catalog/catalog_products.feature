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
