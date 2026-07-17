# language: pt

@authenticated
Funcionalidade: Taxonomias autenticadas

  Esquema do Cenário: Consultar taxonomia autenticada
    Quando eu fizer uma requisição GET autenticada para a taxonomia "<endpoint>"
    Então devo receber status code 200
    E devo validar o contrato da resposta de taxonomia autenticada
    E a resposta autenticada de taxonomia não deve expor campos internos proibidos

    Exemplos:
      | endpoint        |
      | /me/brands      |
      | /me/categories  |
      | /me/collections |
      | /me/tags        |
