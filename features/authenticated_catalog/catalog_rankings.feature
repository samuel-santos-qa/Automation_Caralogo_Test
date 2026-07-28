# language: pt

@authenticated
Funcionalidade: Rankings do catálogo autenticado

  Cenário: Listar produtos por maior comprimento total
    Quando eu consultar o ranking autenticado de produtos por comprimento total
    Então devo receber status code 200
    E devo validar a paginação da lista autenticada de rankings
    E devo validar o resumo da lista autenticada de rankings
    E a lista autenticada de rankings não deve estar vazia
    E devo validar o contrato dos rankings autenticados retornados
    E os rankings autenticados devem estar ordenados do maior para o menor
    E a resposta autenticada de rankings não deve expor campos administrativos internos
