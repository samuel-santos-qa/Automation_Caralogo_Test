# language: pt

Funcionalidade: Paginação pública do catálogo

  Cenário: Consultar catálogo público com paginação válida
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens com paginação válida
    Então devo receber status code 200
    E devo validar os dados de paginação pública
    E a resposta não deve expor campos proibidos

  Esquema do Cenário: Consultar catálogo público com paginação inválida
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens com paginação inválida "<query>"
    Então devo receber status code 400
    E a resposta não deve expor campos proibidos

    Exemplos:
      | query        |
      | page=abc     |
      | pageSize=abc |
      | page=0       |
      | pageSize=0   |
