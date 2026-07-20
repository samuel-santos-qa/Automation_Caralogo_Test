# language: pt

@authenticated
Funcionalidade: Listagem de itens autenticados

  Cenário: Consultar meus itens
    Quando eu fizer uma requisição GET autenticada para meus itens
    Então devo receber status code 200
    E devo validar o contrato da paginação dos itens autenticados
    E devo validar o contrato dos itens autenticados retornados
    E a resposta autenticada de itens não deve expor campos internos proibidos
